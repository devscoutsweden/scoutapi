class FavouriteActivity < ActiveRecord::Base
  validates :user, :activity, presence: true

  belongs_to :user
  belongs_to :activity
end
