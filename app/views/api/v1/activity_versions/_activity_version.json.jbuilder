#TODO: Refactor back to activity_version instead of @activityVersion
json.id @activityVersion.activity_id
json.revision_id @activityVersion.id

# Number of users who have marked the activity as a favourite
#json.favourites_count @favouritesCount[activity_version.activity_id].nil? ? 0 : @favouritesCount[activity_version.activity_id]

#json.ratings_count @ratingsData[activity_version.activity.id][:count] if @ratingsData[activity_version.activity.id]
#json.ratings_average @ratingsData[activity_version.activity.id][:average] if @ratingsData[activity_version.activity.id]

#json.ratings_count activity_version.ratings_count
#json.ratings_average activity_version.ratings_average

@activity_version_attrs.each { |key| json.set! key, @activityVersion.public_send(key) }

if @attrs.include? 'categories'
  json.categories @activityVersion.categories, partial: 'api/v1/categories/category', as: :category
end
if @attrs.include? 'media_files'
  json.media_files @activityVersion.media_files, partial: 'api/v1/media_files/media_file', as: :media_file
end
if @attrs.include? 'references'
  json.references @activityVersion.references, :id, :description, :uri
end