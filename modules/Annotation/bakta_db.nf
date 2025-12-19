process BAKTA_DB_DOWNLOAD {
    conda "bioconda::bakta=1.11.4"

    output:
    path "db/db-light"

    script:
    """
    if [ ! -d db/db-light ]; then
        bakta_db download --output db/db-light --type light
    fi
    """
}