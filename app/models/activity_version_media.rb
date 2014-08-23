class ActivityVersionMedia < ActiveRecord::Base
  belongs_to :activity_version
  belongs_to :media_file
end
