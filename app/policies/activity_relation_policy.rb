class ActivityRelationPolicy < ApplicationPolicy

  def index?
    true
  end

  def create?
    User.roles[user.role] >= PERMISSIONS[:activity_edit] || (record.related_activity.user == user && User.roles[user.role] >= PERMISSIONS[:activity_edit_own])
  end

  def destroy?
    update?
  end

  def set_auto_generated?
    User.roles[user.role] >= PERMISSIONS[:activity_edit]
  end
end