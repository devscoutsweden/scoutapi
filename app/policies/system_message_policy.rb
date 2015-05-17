class SystemMessagePolicy < ApplicationPolicy

  def index?
    User.roles[user.role] >= PERMISSIONS[:system_message_read]
  end

  def show?
    index?
  end

  def update?
    User.roles[user.role] >= PERMISSIONS[:system_message_manage]
  end

  def create?
    update?
  end

  def destroy?
    update?
  end
end