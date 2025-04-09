call _.drop('auth.setting');

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
    when 'login_max_attempts' then _.get_current_setting('auth.login_max_attempts', '${AUTH_LOGIN_MAX_ATTEMPTS}')
    when 'lockout_interval' then _.get_current_setting('auth.lockout_interval', '${AUTH_LOCKOUT_INTERVAL}')
    when 'min_password_length' then _.get_current_setting('auth.min_password_length', '${AUTH_MIN_PASSWORD_LENGTH}')
    when 'required_uppercase' then _.get_current_setting('auth.required_uppercase', '${AUTH_REQUIRED_UPPERCASE}')
    when 'required_lowercase' then _.get_current_setting('auth.required_lowercase', '${AUTH_REQUIRED_LOWERCASE}')
    when 'required_number' then _.get_current_setting('auth.required_number', '${AUTH_REQUIRED_NUMBER}')
    when 'required_special' then _.get_current_setting('auth.required_special', '${AUTH_REQUIRED_SPECIAL}')
    
    when 'default_roles' then _.get_current_setting('auth.default_roles', '${AUTH_DEFAULT_ROLES}')
    when 'default_scheme' then _.get_current_setting('auth.default_scheme', '${AUTH_DEFAULT_SCHEME}')
    
    when 'require_email_confirmation' then _.get_current_setting('auth.require_email_confirmation', '${AUTH_REQUIRE_EMAIL_CONFIRMATION}')
    
    when 'email_confirmation_code_len' then _.get_current_setting('auth.email_confirmation_code_len', '${AUTH_EMAIL_CONFIRMATION_CODE_LEN}')
    when 'email_confirmation_link_expires_in' then _.get_current_setting('auth.email_confirmation_link_expires_in', '${AUTH_EMAIL_CONFIRMATION_LINK_EXPIRES_IN}')
    when 'email_confirmation_max_attempts' then _.get_current_setting('auth.email_confirmation_max_attempts', '${AUTH_EMAIL_CONFIRMATION_MAX_ATTEMPTS}')
    when 'email_confirmation_retry_interval' then _.get_current_setting('auth.email_confirmation_retry_interval', '${AUTH_EMAIL_CONFIRMATION_RETRY_INTERVAL}')
    
    when 'email_reset_code_len' then _.get_current_setting('auth.email_reset_code_len', '${AUTH_EMAIL_RESET_CODE_LEN}')
    when 'email_reset_link_expires_in' then _.get_current_setting('auth.email_reset_link_expires_in', '${AUTH_EMAIL_RESET_LINK_EXPIRES_IN}')
    when 'email_reset_form_expires_in' then _.get_current_setting('auth.email_reset_form_expires_in', '${AUTH_EMAIL_RESET_FORM_EXPIRES_IN}')
    when 'email_reset_max_attempts' then _.get_current_setting('auth.email_reset_max_attempts', '${AUTH_EMAIL_RESET_MAX_ATTEMPTS}')
    when 'email_reset_retry_interval' then _.get_current_setting('auth.email_reset_retry_interval', '${AUTH_EMAIL_RESET_RETRY_INTERVAL}')

    else null
end;
$$;

