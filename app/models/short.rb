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
  CODE_GENERATION_ATTEMPS = 10
  DEFAULT_RANDOM_LENGTH   = 6
  INVALID_FULL_CHARS      = /[<>]+/
  VALID_SHORT_URL_CHARS   = /\A[a-zA-Z0-9\-_+]+\z/

  before_validation :generate_short

  validates :full_url,  presence: true,
                        format: { without: INVALID_FULL_CHARS, message: :blocked_chars }
  validates :short_url, presence: true, uniqueness: true,
                        format: { with: VALID_SHORT_URL_CHARS, message: :invalid_chars }

  def marshall
    { created_at: created_at.iso8601, full_url: full_url, short_url: short_url }
  end

  private

  def generate_short
    return nil if short_url.present?

    code     = generate_code
    attempts = CODE_GENERATION_ATTEMPS
    while attempts.positive? && !code_valid?(code)
      code = generate_code
      attempts -= 1
    end
    self.short_url = attempts.zero? ? nil : code
  end

  def generate_code
    SecureRandom.base64(DEFAULT_RANDOM_LENGTH).gsub('/', '_').gsub('=', '-')
  end

  def code_valid?(code)
    Short.where(short_url: code).count.zero?
  end
end
