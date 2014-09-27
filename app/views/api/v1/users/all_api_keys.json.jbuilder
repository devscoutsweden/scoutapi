users ||= @users

json.array! users do |user|
  json.extract! user, :email, :display_name
  json.keys user.user_api_keys do |key|
    json.extract! key, :key
  end
end
