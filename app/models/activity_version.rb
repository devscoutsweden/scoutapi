class ActivityVersion < ActiveRecord::Base
  validates :descr_material, length: {maximum: 10000}
  validates :descr_introduction, length: {maximum: 10000}
  validates :descr_main, length: {maximum: 10000}
  validates :descr_notes, length: {maximum: 10000}
  validates :descr_prepare, length: {maximum: 10000}
  validates :descr_safety, length: {maximum: 10000}
  validates :name, length: {maximum: 100}
  validates :age_min, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates :age_max, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates :participants_min, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10000}
  validates :participants_max, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10000}
  validates :time_min, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10080} # 10080 minutes = 7 days
  validates :time_max, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10080} # 10080 minutes = 7 days
  belongs_to :activity
  belongs_to :user
  has_and_belongs_to_many :references, :autosave => true
  has_and_belongs_to_many :categories, :autosave => true
  has_many :activity_version_medias
  #has_many :medias, through => :activity_version_medias
end
