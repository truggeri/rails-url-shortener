# == Schema Information
#
# Table name: shorts
#
#  id             :bigint           not null, primary key
#  full_url       :string           not null
#  short_url      :string           not null
#  user_generated :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_shorts_on_short_url  (short_url)
#
class Short < ApplicationRecord
  DEFAULT_RANDOM_LENGTH = 8
  VALID_SHORT_URL_CHARS = /\A[a-zA-Z0-9\-_]+\z/

  before_validation :generate_short

  validates :full_url,  presence: true
  validates :short_url, presence: true, uniqueness: true,
                        format: { with: VALID_SHORT_URL_CHARS, message: :invalid_chars }

  def marshall
    { created_at: created_at.iso8601, full_url: full_url, short_url: short_url }
  end

  private

  def generate_short
    self.short_url = generate_code unless short_url.present?
  end

  def generate_code
    SecureRandom.base64(DEFAULT_RANDOM_LENGTH).gsub('/', '-').gsub('=', '_')
  end
end
