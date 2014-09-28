class Rating < ActiveRecord::Base
  validates :user, :activity, presence: true

  belongs_to :activity
  belongs_to :user
end
