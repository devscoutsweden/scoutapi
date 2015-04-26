class ActivityRelation < ActiveRecord::Base
  validates :user, :activity, :related_activity, presence: true

  belongs_to :activity, :class_name => :Activity, touch: true # touch => updates the updated_at timestamp of the activity when new relations are added.
  belongs_to :related_activity, :class_name => :Activity
  belongs_to :user, :class_name => :User, :foreign_key => :owner_id
end
