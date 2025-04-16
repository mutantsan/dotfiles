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

    if ! pyenv versions --bare | grep -Fxq "$python_version"; then
        echo "\n❌ Python $python_version is not installed in pyenv."
        echo "Run: 'pyenv install $python_version' or change the version."
        echo "Available versions:"
        pyenv versions
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
    docker exec -it pg17 createdb -O ckan_default ${project_name}
    docker exec -it pg17 psql -U root -d ${project_name} -c "CREATE EXTENSION IF NOT EXISTS postgis;" >/dev/null 2>&1
    echo "💾 Database ${project_name} and PostGIS extension has been created"

    docker exec -it solr8 solr create_core -c ${project_name} >/dev/null 2>&1
    echo "🔍 Solr core ${project_name} has been created"

    # creating .envrc for direnv
    echo "layout pyenv $python_version" >.envrc
    echo 'export CKAN_INI=$PWD/config/ckan.ini' >>.envrc
    echo 'export SETUPTOOLS_ENABLE_FEATURES="legacy-editable"' >>.envrc
    echo 'export PYTHONBREAKPOINT="ipdb.set_trace"' >>.envrc
    echo "unset PS1" >>.envrc

    echo "✅ CKAN project '$project_name' initialized with Python $python_version\n"

    direnv allow
}
