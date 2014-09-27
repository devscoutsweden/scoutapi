class MediaFile < ActiveRecord::Base
  has_and_belongs_to_many :activity_versions
end
