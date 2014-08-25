activity ||= @activity

#if @all_versions
#  json.partial! activity
#else
  json.partial! activity.activity_versions.last
#end
