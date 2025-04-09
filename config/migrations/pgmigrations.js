module.exports = {
    env: "./config/.env",
    psql: "/usr/bin/psql",
    pgdump: "/usr/bin/pg_dump",

    host: "${PGHOST}",
    port: "${PGPORT}",
    dbname: "${PGDATABASE}",
    username: "${PGUSER}",
    password: "${PGPASSWORD}",

    // versioned migrations "V[version]__name.sql"
    upPrefix: "V",
    // versioned down  (undo) migrations "U[version]__name.sql"
    downPrefix: "U",
    // repeatable migrations "R__name.sql"
    repetablePrefix: "R",
    // repeatable before versioned migrations "R_before__name.sql" 
    repetableBeforePrefix: "_R",
    // before migrations "_B__name.sql", run always
    beforePrefix: "_B",
    // after migrations "_A__name.sql", run always
    afterPrefix: "_A",
    // separator between prefix and name
    separatorPrefix: "__",
    // finalize prefix
    finalizePrefix: "TEST",
    
    // root directory of the migrations
    migrationDir: "./src/backend/",

    // ignore file or directory names that match this pattern
    skipPattern: "${SKIP_PATTERN}",

    // includes subdirectories too
    recursiveDirs: true,

    // order the migrations based on the directory first and second based on migration type
    dirsOrderedByName: true,

    // order directories same as Visual Studio Code Explorer would (natural order)
    dirsNaturalOrder: true,
    
    // for versioned migrations add the top level directory name to version number
    appendTopDirToVersion: true,

    // for versioned migrations add the top level directory name to version number, but split by this seqeunce
    appendTopDirToVersionSplitBy: "__",

    // for versioned migrations add the top level directory name to version number, but split by this seqeunce and take only the first part
    appendTopDirToVersionPart: 0,
    
    // for versioned migrations run missing versions in between
    runOlderVersions: true
}