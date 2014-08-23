class ActivityVersion < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
  has_and_belongs_to_many :references
  has_and_belongs_to_many :categories
  has_many :activity_version_medias
  #has_many :medias, through => :activity_version_medias
end
