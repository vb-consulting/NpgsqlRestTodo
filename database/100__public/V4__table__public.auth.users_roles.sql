create table auth_users_roles (
    user_id bigint references auth_users 
        on delete cascade deferrable initially immediate,
    role_id int references auth_roles 
        on delete cascade deferrable initially immediate,

    like sys.audit_template including all,

    primary key(user_id, role_id)
);

call sys.add_update_at_trigger('auth_users_roles');
