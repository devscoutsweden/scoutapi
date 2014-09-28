class UserApiKey < ActiveRecord::Base
  validates :user, presence: true

  belongs_to :user

  before_create :generate_key

  private

  def generate_key
    begin
      self.key = SecureRandom.hex(5) # Generate 5 random bytes, which will be returned as 10 hexadecimal characters.
    end while self.class.find_by_key(self.key)
  end
end
