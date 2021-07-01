# == Schema Information
#
# Table name: shorts
#
#  id             :bigint           not null, primary key
#  cost           :integer          not null
#  full_url       :string           not null
#  short_url      :string           not null
#  user_generated :boolean          default(FALSE), not null
#  uuid           :uuid             not null
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
  RESERVED_SHORTS         = %w[admin health status system].freeze
  VALID_SHORT_URL_CHARS   = /\A[a-zA-Z0-9\-_]+\z/

  COST_PER_CONSONANT = 1
  COST_PER_OTHER     = 3
  COST_PER_REPEAT    = 1
  COST_PER_VOWEL     = 2
  VOWELS             = %w[a e i o u].freeze
  CONSONANTS         = ('a'..'z').to_a - VOWELS

  before_save       :generate_uuid
  before_validation :generate_short
  before_validation :calculate_cost

  validates :cost,      numericality: { only_integer: true, greater_than: 0 }
  validates :full_url,  presence: true, length: { in: 3..500 },
                        format: { without: INVALID_FULL_CHARS, message: :blocked_chars }
  validates :short_url, presence: true, uniqueness: true, length: { in: 4..100 },
                        format: { with: VALID_SHORT_URL_CHARS, message: :invalid_characters },
                        exclusion: { in: RESERVED_SHORTS, message: :reserved }

  def marshall
    { cost: cost, created_at: created_at.iso8601, full_url: full_url, short_url: short_url, token: token }
  end

  private

  def generate_short
    return nil if short_url.present?

    id       = (last_short_id.presence || 0) + 1
    code     = generate_code(id)
    attempts = CODE_GENERATION_ATTEMPS
    while attempts.positive? && !code_valid?(code)
      id += 997
      code = generate_code(id)
      attempts -= 1
    end
    self.short_url = attempts.zero? ? nil : code
  end

  def last_short_id
    Short.limit(1).order(id: :desc).pluck(:id).first
  end

  def generate_code(number)
    Slug.new(number).generate
  end

  def code_valid?(code)
    Short.where(short_url: code).count.zero?
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def token
    Token.encode({ iat: created_at.to_i, uuid: uuid })
  end

  def calculate_cost
    return nil if cost.present? || short_url.nil?

    tally      = 0
    used_chars = {}

    short_url.chars.each do |char|
      tally += cost_for(char)
      if used_chars[char]
        tally += COST_PER_REPEAT
      else
        used_chars[char] = true
      end
    end

    self.cost = tally
  end

  def cost_for(char)
    if char.in?(VOWELS)
      COST_PER_VOWEL
    elsif char.in?(CONSONANTS)
      COST_PER_CONSONANT
    else
      COST_PER_OTHER
    end
  end
end
