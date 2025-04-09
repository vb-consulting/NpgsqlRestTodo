create table auth_user_providers (
    user_id bigint not null references auth_users 
        on delete cascade deferrable initially immediate,
    provider_id int not null references auth_roles 
        on delete cascade deferrable initially immediate,

    primary key(user_id, provider_id)
);

call temporal.init('auth_user_providers');