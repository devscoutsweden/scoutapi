class User < ActiveRecord::Base
  # The different roles and their "levels". The values should match those used in ApplicationPolicy::PERMISSIONS.
  enum role: {limited_user: -1, user: 0, moderator: 10, administrator: 20}

  after_initialize :set_default_role, :if => :new_record?

  has_many :user_identities, :dependent => :delete_all
  has_many :user_api_keys, :dependent => :delete_all
  has_many :activities
  has_many :comments, :dependent => :delete_all
  has_many :favourite_activities, :dependent => :delete_all
  has_many :favourites, :through => :favourite_activities, :source => :activity
  has_many :ratings, :dependent => :delete_all
  has_many :activity_versions
  has_many :activity_relations
  has_many :system_messages

  # Return sorted list of permissions which user has based on their role
  def role_permissions
    ApplicationPolicy::PERMISSIONS.select { |k, v| v <= User.roles[role] }.keys.sort
  end

  def set_default_role
    self.role ||= :user
  end
end
