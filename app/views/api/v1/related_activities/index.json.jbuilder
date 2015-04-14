related_activities ||= @related_activities

json.array! related_activities do |related_activity|
  json.partial! related_activity
end