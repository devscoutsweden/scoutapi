class ApplicationPolicy
  attr_reader :user, :record

  PERMISSIONS = {
      #
      # Permissions for all users (level <0):
      #

      system_message_read: -100,

      #
      # Permissions for regular users (level 0):
      #

      comment_create: 0,

      activity_create: 0,
      activity_edit_own: 0,
      comment_edit_own: 0,
      auth_profile_edit: 0,

      # Permission to set personal rating for any activity. NOT the same as changing other users' ratings.
      rating_set_own: 0,

      # Create media items, e.g. by uploading a photo, associated with activities created by same user
      #mediaitem_create_ownactivity: 0,
      mediaitem_edit_own: 0,

      # Create media items, e.g. by uploading a photo, associated with activities created by same user
      #reference_create_ownactivity: 0,
      reference_edit_own: 0,

      #
      # Permissions for moderators (level 10):
      #

      activity_edit: 10,
      #activity_edit_withoutreview: 10,
      comment_edit: 10,
      #comment_create_withoutreview: 10,
      category_create: 10,
      category_edit: 10,

      # Create media items, e.g. by uploading a photo, associated with any activity
      mediaitem_create: 10,
      reference_create: 10,

      # Assign user's role (or lesser) to any user with a role lesser than the user.
      auth_role_assignown: 10,

      #
      # Permissions for administrators (level 20):
      #

      system_message_create: 20,
      system_message_edit: 20,
      auth_role_assign: 20,
      auth_role_list: 20,
      auth_user_edit: 20,
      auth_user_create: 20,
      mediaitem_edit: 20,
      reference_edit: 20
  }

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
