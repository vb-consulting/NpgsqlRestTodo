create table auth_data_protection_keys (
    name text not null primary key,
    data text not null
);

call temporal.init('auth_data_protection_keys');