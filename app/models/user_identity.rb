class UserIdentity < ActiveRecord::Base
  validates :user, presence: true

  # Table has column named "type", but this is a reserved word and causes this error:
  # "ActiveRecord::SubclassNotFound: The single-table inheritance mechanism failed to locate the subclass".
  #
  # Fix by changing the name for where Rails looks for inheritance information, as per
  # http://stackoverflow.com/questions/17879024/activerecordsubclassnotfound-the-single-table-inheritance-mechanism-failed-to
  self.inheritance_column = :_type_disabled

  belongs_to :user
end
