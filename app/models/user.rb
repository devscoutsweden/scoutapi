class User < ActiveRecord::Base
  has_many :user_identities
  has_many :activities
  has_many :comments
  has_many :favourite_activities
  has_many :ratings
  has_many :activity_versions
end
