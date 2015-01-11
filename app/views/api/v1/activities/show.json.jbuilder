activity ||= @activity

if @all_versions
  json.partial! activity
else
  #TODO: Inline value of @activityVersion
  @activityVersion = activity.activity_versions.order(:id).last
  json.partial! @activityVersion
end
