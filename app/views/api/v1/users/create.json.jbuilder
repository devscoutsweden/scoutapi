user ||= @user

json.api_key user.user_api_keys.order(:id).last.key
