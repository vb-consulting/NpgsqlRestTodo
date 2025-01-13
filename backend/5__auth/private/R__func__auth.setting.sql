call sys.drop('auth.setting');

create function auth.setting(
    _key text
)
returns text
language sql
stable
parallel safe
as
$$
select case _key
    when 'algorithm' then sys.get_current_setting('auth.algorithm', '${AUTH_ALGORITHM}')
    when 'max_attempts' then sys.get_current_setting('auth.max_attempts', '${AUTH_MAX_ATTEMPTS}')
    when 'lockout_interval' then sys.get_current_setting('auth.lockout_interval', '${AUTH_LOCKOUT_INTERVAL}')
    when 'max_password_length' then sys.get_current_setting('auth.max_password_length', '${AUTH_MAX_PASSWORD_LENGTH}')
    when 'min_password_length' then sys.get_current_setting('auth.min_password_length', '${AUTH_MIN_PASSWORD_LENGTH}')
    when 'required_uppercase' then sys.get_current_setting('auth.required_uppercase', '${AUTH_REQUIRED_UPPERCASE}')
    when 'required_lowercase' then sys.get_current_setting('auth.required_lowercase', '${AUTH_REQUIRED_LOWERCASE}')
    when 'required_number' then sys.get_current_setting('auth.required_number', '${AUTH_REQUIRED_NUMBER}')
    when 'required_special' then sys.get_current_setting('auth.required_special', '${AUTH_REQUIRED_SPECIAL}')
    when 'default_roles' then sys.get_current_setting('auth.default_roles', '${AUTH_DEFAULT_ROLES}')
    when 'default_scheme' then sys.get_current_setting('auth.default_scheme', '${AUTH_DEFAULT_SCHEME}')
    when 'require_email_confirmation' then sys.get_current_setting('auth.require_email_confirmation', '${AUTH_REQUIRE_EMAIL_CONFIRMATION}')
    when 'email_confirmation_code_len' then sys.get_current_setting('auth.email_confirmation_code_len', '${AUTH_EMAIL_CONFIRMATION_CODE_LEN}')
    when 'email_confirmation_expires_in' then sys.get_current_setting('auth.email_confirmation_expires_in', '${AUTH_EMAIL_CONFIRMATION_EXPIRES_IN}')
    else null
end;
$$;

