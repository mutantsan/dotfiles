update_solr_schema() {
    local schema_path="$1"
    local core_name="$2"
    local container="solr9"
    local target="/var/solr/data/${core_name}/conf/managed-schema.xml"


    if [[ -z "$schema_path" || -z "$core_name" ]]; then
        echo "Usage: update_solr_schema <schema-path> <core-name>"
        return 1
    fi

    if [[ ! -f "$schema_path" ]]; then
        echo "Schema file not found: $schema_path"
        return 1
    fi

    echo "Copying schema to ${container}:${target}..."
    docker cp "$schema_path" "${container}:${target}" || return 1

    echo "Changing ownership to solr:solr..."
    sudo docker exec --user root "$container" \
        chown solr:solr "$target" || return 1


    echo "Restarting Solr..."
    docker restart "$container" || return 1

    echo "Solr schema updated and container restarted."
}

fix_solr_jts() {
    local core_name="$1"
    local container="solr9"
    local core_dir="/var/solr/data/${core_name}"
    local lib_dir="/opt/solr/server/solr-webapp/webapp/WEB-INF/lib"
    local jts_version="1.19.0"
    local jar="jts-core-${jts_version}.jar"
    local url="https://repo1.maven.org/maven2/org/locationtech/jts/jts-core/${jts_version}/${jar}"
    local bundled

    if [[ -z "$core_name" ]]; then
        echo "Usage: fix_solr_jts <core-name>"
        return 1
    fi

    if ! docker exec "$container" test -d "$core_dir"; then
        echo "Solr core not found: ${container}:${core_dir}"
        return 1
    fi

    # Prefer the jar shipped with Solr, download it otherwise
    bundled=$(docker exec "$container" bash -c "find -L /opt/solr/modules -name '${jar}' 2>/dev/null | head -1")
    if [[ -n "$bundled" ]]; then
        echo "Copying bundled ${jar} to ${container}:${lib_dir}..."
        docker exec --user root "$container" cp "$bundled" "${lib_dir}/${jar}" || return 1
    else
        echo "Downloading ${jar} to ${container}:${lib_dir}..."
        docker exec --user root "$container" curl -fsSL -o "${lib_dir}/${jar}" "$url" || return 1
    fi
    docker exec --user root "$container" chmod 644 "${lib_dir}/${jar}" || return 1

    echo "Restarting Solr..."
    docker restart "$container" >/dev/null || return 1

    echo "Waiting for core ${core_name}..."
    local i code
    for i in {1..30}; do
        code=$(curl -s -m 5 -o /dev/null -w '%{http_code}' \
            "http://127.0.0.1:8983/solr/${core_name}/select?q=*:*&rows=0")
        if [[ "$code" == "200" ]]; then
            echo "JTS ${jts_version} installed, core ${core_name} is up."
            return 0
        fi
        # Solr answers but the core failed to load: no point waiting
        if [[ "$code" == "500" ]]; then
            echo "Core ${core_name} failed to load (HTTP 500), check: docker logs ${container}"
            return 1
        fi
        sleep 2
    done

    echo "Core ${core_name} did not respond after restart, check: docker logs ${container}"
    return 1
}
