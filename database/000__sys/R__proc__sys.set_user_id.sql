call sys.drop('sys.set_user_id');

create procedure sys.set_user_id(_id bigint)
language sql
as
$$
call sys.set_current_setting(
    'sys.user_id',
   _id::text
);
$$;
