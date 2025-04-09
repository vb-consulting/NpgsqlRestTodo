//
// local configuration for PostgreSQL migrations to be used outside of Docker
// see package.json scripts db-*
// Note: Requires psql local client tools to be installed (try sudo apt install postgresql-client-17)
//
module.exports = {
    psql: "psql",
    pgdump: "pg_dump",
    host: "127.0.0.1"
}
