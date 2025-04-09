create table auth_user_profiles (
    user_id bigint not null primary key references auth_users,
    name text null,
    image_id bigint null references auth_profile_images on delete set null deferrable initially immediate,
    preferences jsonb not null default '{}'::jsonb,
    like _.audit_template including all
);

call _.add_audit_trigger('auth_user_profiles');
call temporal.init('auth_user_profiles');