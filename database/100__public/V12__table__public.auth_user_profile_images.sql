create table auth_profile_images (
    image_id bigint not null primary key,
    lo_oid oid null,
    url_path text null,
    medatadata json not null,
    check (lo_oid is not null or url_path is not null),
    like sys.audit_template including all
);

call sys.add_audit_trigger('auth_profile_images');

