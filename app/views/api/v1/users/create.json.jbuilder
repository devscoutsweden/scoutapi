user ||= @user

json.api_key user.user_api_keys.last.key
