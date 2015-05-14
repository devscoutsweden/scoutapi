class ActivityPolicy < ApplicationPolicy

  def index?
    true
  end

  def update?
    User.roles[user.role] >= PERMISSIONS[:activity_edit] || (record.user == user && User.roles[user.role] >= PERMISSIONS[:activity_edit_own])
  end

  def show?
    true
  end

  def create?
    User.roles[user.role] >= PERMISSIONS[:activity_create]
  end

  def destroy?
    update?
  end
end