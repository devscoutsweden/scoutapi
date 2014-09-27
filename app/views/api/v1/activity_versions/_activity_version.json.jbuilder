json.id activity_version.activity.id
json.revision_id activity_version.id
json.extract! activity_version,
              :name,
              :descr_introduction,
              :descr_main,
              :descr_material,
              :descr_notes,
              :descr_prepare,
              :descr_safety,
              :featured,
              :age_max,
              :age_min,
              :participants_max,
              :participants_min,
              :time_max,
              :time_min,
              :published_at,
              :status,
              :created_at

json.categories activity_version.categories, :id, :group, :name
json.references activity_version.references, :id, :description, :uri
json.media_files activity_version.media_files, :id, :mime_type, :data, :uri, :status
