class User < ActiveRecord::Base
  has_many :user_identities, :dependent => :delete_all
  has_many :user_api_keys, :dependent => :delete_all
  has_many :activities
  has_many :comments, :dependent => :delete_all
  has_many :favourite_activities, :dependent => :delete_all
  has_many :favourites, :through => :favourite_activities, :source => :activity
  has_many :ratings, :dependent => :delete_all
  has_many :activity_versions
end
