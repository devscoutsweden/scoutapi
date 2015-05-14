class UserPolicy < ApplicationPolicy

  def index?
    update?
  end

  def update?
    User.roles[user.role] >= PERMISSIONS[:auth_user_edit]
  end

  def show?
    true
  end

  def destroy?
    update?
  end

  def create?
    User.roles[user.role] >= PERMISSIONS[:auth_user_create]
  end

  def profile?
    true
  end

  def all_api_keys?
    update?
  end

  def update_profile?
    User.roles[user.role] >= PERMISSIONS[:auth_profile_edit]
  end
end