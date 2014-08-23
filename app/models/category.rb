class Category < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :user
  has_and_belongs_to_many :activity_versions
end
