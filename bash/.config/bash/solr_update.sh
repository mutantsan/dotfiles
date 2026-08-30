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
