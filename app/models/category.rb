class Category < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  # Do not validate that each category has a user since. Reason: some existing
  # categories were created before user_id was automatically assigned based on
  # the API key used when creating the category

  #validates :user, presence: true

  belongs_to :user
  has_and_belongs_to_many :activity_versions
end
