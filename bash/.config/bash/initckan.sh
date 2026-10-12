# This function initializes a CKAN project with a specified Python version.
# Adds necessary environment variables to the .envrc file for direnv.
# And creates a CKAN configuration file in the config directory.

# SETUPTOOLS_ENABLE_FEATURES tells setuptools to enable the old-style "editable installs"
# (i.e., python setup.py develop behavior or pip install -e . using legacy methods).

# unset PS1 - removing the primary shell prompt variable,
initckan() {
    local project_name="$1"
    local python_version="$2"

    if [[ -z "$project_name" || -z "$python_version" ]]; then
        echo "ℹ️ Usage: initckan <project_name> <python_version>"
        return 1
    fi

    if ! command -v uv >/dev/null 2>&1; then
        echo "\n❌ uv is not installed."
        return 1
    fi

    # Downloads the interpreter if uv does not have it yet; a no-op otherwise.
    if ! uv python install "$python_version"; then
        echo "\n❌ uv could not provide Python $python_version."
        return 1
    fi

    echo "Initializing CKAN project $project_name with Python version: $python_version\n"

    echo "📁 Creating project directory: $project_name"
    mkdir -p "$project_name"
    cd "$project_name" || return 1

    mkdir -p config/storage/webassets

    # copy the default CKAN config file to the config directory
    export PROJECT_NAME="$project_name"
    envsubst <"$MY_CONF_DIR/templates/ckan.ini" >./config/ckan.ini

    # initializing solr core and postgres db with docker
    docker exec -it pg18 psql -U root -c "CREATE USER ckan_default WITH PASSWORD 'pass' NOSUPERUSER NOCREATEDB NOCREATEROLE;"
    docker exec -it pg18 psql -U root -c "CREATE USER datastore_default WITH PASSWORD 'pass' NOSUPERUSER NOCREATEDB NOCREATEROLE;"
    docker exec -it pg18 psql -U root -c "CREATE EXTENSION IF NOT EXISTS vector; CREATE EXTENSION IF NOT EXISTS postgis;"  >/dev/null 2>&1
    docker exec -it pg18 createdb -O ckan_default ${project_name}
    echo "💾 Database ${project_name} and PostGIS extension has been created"

    docker exec -it solr9 solr create_core -c ${project_name} >/dev/null 2>&1
    echo "🔍 Solr core ${project_name} has been created"

    # creating .envrc for direnv
    # The venv lives in .venv; .envrc recreates it if it goes missing.
    echo "[[ -d .venv ]] || uv venv --seed --python $python_version" >.envrc
    echo 'export VIRTUAL_ENV="$PWD/.venv"' >>.envrc
    echo 'PATH_add "$VIRTUAL_ENV/bin"' >>.envrc
    echo 'export CKAN_INI=$PWD/config/ckan.ini' >>.envrc
    echo 'export SETUPTOOLS_ENABLE_FEATURES="legacy-editable"' >>.envrc
    echo 'export PYTHONBREAKPOINT="ipdb.set_trace"' >>.envrc
    echo 'export CDM_USE_UV=1' >>.envrc
    # Node 24: from fnm where it's installed (NixOS), nvm otherwise. direnv's
    # `use node` can't read fnm's layout, so there the bin dir is added directly.
    if command -v fnm >/dev/null 2>&1; then
        fnm exec --using=24 true >/dev/null 2>&1 || fnm install 24
        echo 'PATH_add "$(dirname "$(fnm exec --using=24 node -p process.execPath)")"' >>.envrc
    else
        echo 'export NODE_VERSIONS="$HOME/.nvm/versions/node"' >>.envrc
        echo 'export NODE_VERSION_PREFIX=v' >>.envrc
        echo "use node 24" >>.envrc
    fi
    echo "unset PS1" >>.envrc

    echo "✅ CKAN project '$project_name' initialized with Python $python_version\n"

    direnv allow
}
