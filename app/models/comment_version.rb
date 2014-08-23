class CommentVersion < ActiveRecord::Base
  belongs_to :comment
  has_and_belongs_to_many :media_files
end
