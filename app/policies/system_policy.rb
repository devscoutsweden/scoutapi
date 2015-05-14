class SystemPolicy < Struct.new(:user, :system)

  def ping?
    true
  end

  def roles?
    User.roles[user.role] >= ApplicationPolicy::PERMISSIONS[:auth_role_list]
  end

end