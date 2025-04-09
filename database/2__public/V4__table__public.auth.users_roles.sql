create table auth_users_roles (
    user_id bigint not null references auth_users 
        on delete cascade deferrable initially immediate,
    role_id int not null references auth_roles 
        on delete cascade deferrable initially immediate,

    like _.audit_template including all,

    primary key(user_id, role_id)
);

call _.add_audit_trigger('auth_users_roles');
call temporal.init('auth_users_roles');