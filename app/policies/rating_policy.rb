class RatingPolicy < ApplicationPolicy

  def show?
    User.roles[user.role] >= PERMISSIONS[:rating_set_own]
  end

  def create?
    show?
  end

  def destroy?
    show?
  end
end