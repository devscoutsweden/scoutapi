json.extract! category,
              :id,
              :group,
              :name,
              #:status,
              #:created_at,
              :updated_at
#json.group category.group.force_encoding("ISO-8859-1")
#json.name category.name.force_encoding("ISO-8859-1")
json.media_file do
  json.partial! category.media_file
end unless category.media_file.nil?
