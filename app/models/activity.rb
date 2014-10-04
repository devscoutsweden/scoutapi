class Activity < ActiveRecord::Base
  # Do not validate that each activity is owned by a user. Reason: some existing
  # activities were created before user_id was automatically assigned based on
  # the API key used when creating the activity.

  #validates :user, presence: true

  belongs_to :user
  has_many :activity_versions, :dependent => :delete_all
  has_many :ratings, :dependent => :delete_all
  has_many :comments, :dependent => :delete_all
  has_many :favourite_activities, :dependent => :delete_all
end
