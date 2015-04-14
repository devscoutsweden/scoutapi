class Activity < ActiveRecord::Base
  # Do not validate that each activity is owned by a user. Reason: some existing
  # activities were created before user_id was automatically assigned based on
  # the API key used when creating the activity.

  #validates :user, presence: true

  # Non-persisted attributes used to store derived/calculated activity statistics
  attr_accessor :favourite_count, :ratings_count, :ratings_average, :my_rating

  belongs_to :user
  has_many :activity_versions, :dependent => :delete_all
  has_many :ratings, :dependent => :delete_all
  has_many :comments, :dependent => :delete_all
  has_many :favourite_activities, :dependent => :delete_all

  # Use :activity_relations if you want the association table activity_relations (as opposed to records from the activities table)
  has_many :activity_relations,
           :foreign_key => :activity_id,
           :dependent => :delete_all

  has_many :activity_relations_inverse,
           :class_name => :ActivityRelation,
           :foreign_key => :related_activity_id,
           :dependent => :delete_all

  # Use :relations if you want the actual activities which are related to the activity (meaning activities table records as opposed to activity_relations table records)
  has_many :relations,
           :through => :activity_relations,
           :source => :related_activity
end
