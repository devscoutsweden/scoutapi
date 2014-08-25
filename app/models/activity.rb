class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :activity_versions, :dependent => :delete_all
  has_many :ratings, :dependent => :delete_all
  has_many :comments, :dependent => :delete_all
  has_many :favourite_activities, :dependent => :delete_all
end
