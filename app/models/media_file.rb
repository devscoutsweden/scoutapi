class MediaFile < ActiveRecord::Base
  has_many :activity_version_medias
  has_and_belongs_to_many :comment_versions
end
