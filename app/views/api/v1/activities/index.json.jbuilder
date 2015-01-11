revisions ||= @activityVersions

json.array! revisions do |activity_version|
  #TODO: Refactor back to activity_version instead of @activityVersion
  @activityVersion = activity_version
  json.partial! @activityVersion
end
#activities ||= @activities
#
#json.array! @activities do |activity|
#  json.partial! activity
#end
