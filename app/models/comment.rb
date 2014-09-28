class Comment < ActiveRecord::Base
  validates :user, :activity, presence: true

  belongs_to :user
  belongs_to :activity
  has_many :comment_versions
end
