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
if @attrs.include? 'related'
  # Using "activity_relations" instead of "relations" saves SQL calls since :related_activity_id can be returned
  # directoy from the activity_relations table instead of having to also load the associated (i.e. related) activities.
  json.related activity_version.activity.activity_relations, :related_activity_id
end