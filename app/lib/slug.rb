#
# Slug represents a short url slug
#   Taking in an integer number, base 64 conversion is done and the digits are scrambled
# ex: 6020237327 -> "CofR5w"
#
class Slug
  BASE           = 64
  BITS_PER_DIGIT = 6
  CHARACTERS     = 6
  CHAR_MAP = %w[0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z
                A B C D E F G H I J K L M N O P Q R S T U V W X Y Z - _ +].freeze
  DIGIT_MAP = [1, 3, 5, 2, 0, 4].freeze

  def initialize(number)
    @number = number
    raise ArgumentError, 'number must be a number' unless number.is_a?(Integer)
    raise ArgumentError, 'number too large'        if number > BASE**CHARACTERS
    raise ArgumentError, 'number too small'        if number.negative?
  end

  def to_s
    slug
  end

  private

  attr_reader :number

  def slug
    @slug ||= convert_base(number)
  end

  def convert_base(number)
    result    = []
    remaining = number
    position  = CHARACTERS - 1

    while position.positive?
      digit_weight = position * BITS_PER_DIGIT
      digit        = remaining >> digit_weight
      remaining -= digit << digit_weight
      position  -= 1
      result << digit
    end
    result << remaining

    DIGIT_MAP.map { |i| CHAR_MAP[result[i]] }.join
  end
end
