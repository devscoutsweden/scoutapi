class CategoryPolicy < ApplicationPolicy

  def index?
    true
  end

  def update?
    User.roles[user.role] >= PERMISSIONS[:category_edit]
  end

  def show?
    true
  end

  def create?
    User.roles[user.role] >= PERMISSIONS[:category_create]
  end

  def destroy?
    update?
  end
end