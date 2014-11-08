json.id activity_version.activity.id
json.revision_id activity_version.id

# Number of users who have marked the activity as a favourite
json.favourite_count @favouritesCount[activity_version.activity.id].nil? ? 0 : @favouritesCount[activity_version.activity.id]

@activity_version_attrs.each { |key| json.set! key, activity_version.public_send(key) }

if @attrs.include? 'categories'
  json.categories activity_version.categories, partial: 'api/v1/categories/category', as: :category
end
if @attrs.include? 'media_files'
  json.media_files activity_version.media_files, partial: 'api/v1/media_files/media_file', as: :media_file
end
if @attrs.include? 'references'
  json.references activity_version.references, :id, :description, :uri
end