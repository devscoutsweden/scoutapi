class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :activity_versions
  has_many :ratings
  has_many :comments
  has_many :favourite_activities
end
