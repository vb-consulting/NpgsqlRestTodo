create table auth_roles (
    role_id int primary key,
    name text not null,
    description text not null,

    like sys.audit_template including all
);

call sys.add_update_at_trigger('auth_roles');

insert into auth_roles 
    (role_id, name, description) 
values
    (1, 'system', 'system admin, can manage users, todos and everything'),
    (2, 'admin', 'todo admin, can manage other people todos'),
    (3, 'readonly-admin', 'readonly todo admin'),
    (4, 'user', 'can only see and manage its own todos');
