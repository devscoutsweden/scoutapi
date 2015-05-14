user ||= @userApiKey.user

json.extract! user, :email, :display_name, :created_at, :role, :role_permissions

json.keys user.user_api_keys do |key|
  json.extract! key, :key
end
