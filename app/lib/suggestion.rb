require 'set'

#
# Suggestion - Gives a suggested alpha slug that has minimal cost
#
class Suggestion
  def initialize(hostname)
    @hostname = hostname
    validate_inputs!

    @consonants      = [].to_set
    @used_vowels     = []
    @used_consonants = []
    @vowels          = [].to_set
  end

  def slug
    bucket_chars

    result = ''
    while result.length < 4
      char = unused_const.presence || unused_vowel.presence || used_consonant.presence || used_vowel
      raise 'Could not find next character' unless char.present?

      result << char
    end

    result
  end

  private

  attr_reader :consonants, :hostname, :used_consonants, :used_vowels, :vowels

  def validate_inputs!
    raise ArgumentError, 'must provide hostname' if hostname.blank?
  end

  def bucket_chars
    hostname.chars.each do |char|
      if char.in?(Short::VOWELS)
        vowels << char
      else
        consonants << char
      end
    end
  end

  def unused_const
    return nil if consonants.empty?

    char = consonants.first
    used_consonants << char
    consonants.delete(char)
    char
  end

  def unused_vowel
    return nil if vowels.empty?

    char = vowels.first
    used_vowels << char
    vowels.delete(char)
    char
  end

  def used_consonant
    return nil if used_consonants.empty?

    used_consonants[rand(0..(used_consonants.length - 1))]
  end

  def used_vowel
    return nil if used_vowels.empty?

    used_vowels[rand(0..(used_vowels.length - 1))]
  end
end
