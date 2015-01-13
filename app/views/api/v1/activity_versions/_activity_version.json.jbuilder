json.id activity_version.activity_id
json.revision_id activity_version.id

@activity_attrs.each do |key|
  json.set! key, activity_version.activity.public_send(key)
end
@activity_version_attrs.each do |key|
  json.set! key, activity_version.public_send(key)
end

if @attrs.include? 'categories'
  json.categories activity_version.categories, partial: 'api/v1/categories/category', as: :category
end
if @attrs.include? 'media_files'
  json.media_files activity_version.media_files, partial: 'api/v1/media_files/media_file', as: :media_file
end
if @attrs.include? 'references'
  json.references activity_version.references, :id, :description, :uri
end