json.activity_id activity.id
#json.extract! activity,
#              :id,
#              :status

json.array! activity.activity_versions.order(:id) do |activity_version|
  json.partial! activity_version
end
