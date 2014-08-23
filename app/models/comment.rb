class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity
  has_many :comment_versions
end
