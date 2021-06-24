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
    raise ArgumentError, 'number must be an integer' unless number.is_a?(Integer)
    raise ArgumentError, 'number too large'          if number > BASE**CHARACTERS
    raise ArgumentError, 'number too small'          if number.negative?

    @number = number
  end

  def generate
    to_slug(convert_base)
  end

  private

  attr_reader :number

  def convert_base
    remaining = number
    (0..(CHARACTERS - 1)).to_a.reverse.map do |position|
      value, remaining = digit_value(position, remaining)
      value
    end
  end

  def digit_value(digit, full_number)
    return [full_number, 0] if digit.zero?

    digit_shift = digit * BITS_PER_DIGIT
    value       = full_number >> digit_shift
    remaining   = full_number - (value << digit_shift)
    [value, remaining]
  end

  def to_slug(digits)
    DIGIT_MAP.map { |digit| CHAR_MAP[digits[digit]] }.join
  end
end
