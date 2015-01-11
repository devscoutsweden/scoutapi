json.activity_id activity.id
#json.extract! activity,
#              :id,
#              :status

json.array! activity.activity_versions.order(:id) do |activity_version|
  #TODO: Refactor back to activity_version instead of @activityVersion
  @activityVersion = activity_version
  json.partial! @activityVersion
end
