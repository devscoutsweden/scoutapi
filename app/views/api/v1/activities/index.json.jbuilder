revisions ||= @activityVersions

json.array! revisions do |activity_version|
  json.partial! activity_version
end
#activities ||= @activities
#
#json.array! @activities do |activity|
#  json.partial! activity
#end
