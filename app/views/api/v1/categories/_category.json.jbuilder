json.extract! category,
              :id,
              :group,
              :name,
              #:status,
              #:created_at,
              :updated_at
#json.group category.group.force_encoding("ISO-8859-1")
#json.name category.name.force_encoding("ISO-8859-1")

# Number of users who have marked the activity as a favourite
json.activities_count @usageCount[category.id].nil? ? 0 : @usageCount[category.id]

json.media_file do
  json.partial! category.media_file
end unless category.media_file.nil?
