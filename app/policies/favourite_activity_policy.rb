class FavouriteActivityPolicy < ApplicationPolicy

  # No special permission needed to view personal favourites
  def index?
    true
  end

  # No special permission needed to view personal favourites
  def update?
    index?
  end

end