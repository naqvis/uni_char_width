# Provides methods to get fixed width of the unicode character or string.
module UnicodeCharWidth
  VERSION = "0.1.2"

  # returns the number of cells in codepoint
  # see http://www.unicode.org/reports/tr11/
  def self.width(codepoint : Int32)
    default_condition.width(codepoint)
  end

  # return the number of cells in `char'
  def self.width(char : Char)
    width(char.ord)
  end

  # returns string width
  def self.width(str : String)
    default_condition.width(str)
  end

  # return string truncated with `w` cells
  def self.truncate(str : String, w : Int32, tail : String)
    default_condition.truncate(str, w, tail)
  end

  # returns a string wrapped with `w` cells
  def self.wrap(str : String, w : Int32)
    default_condition.wrap(str, w)
  end

  # returns a string filled in left by spaces in `w` cells
  def self.pad_left(str : String, w : Int32)
    default_condition.pad_left(str, w)
  end

  # returns a string filled in right by spaces in `w` cells
  def self.pad_right(str : String, w : Int32)
    default_condition.pad_right(str, w)
  end

  # returns whether is ambiguous width or not
  # EastAsian Ambiguous characters that can be sometimes wide and sometimes
  # narrow and require additional information not contained in the character
  # code to further resolve their width.
  def self.ambiguous?(codepoint : Int32)
    default_condition.ambiguous?(codepoint)
  end

  # returns whether char is ambiguous width or not
  # EastAsian Ambiguous characters that can be sometimes wide and sometimes
  # narrow and require additional information not contained in the character
  # code to further resolve their width.
  def self.ambiguous?(char : Char)
    ambiguous?(char.ord)
  end

  # returns whether is neutral width or not
  # Neutral characters do not occur in legacy East Asian character sets.
  def self.neutral?(codepoint : Int32)
    default_condition.neutral?(codepoint)
  end

  # returns whether char is neutral width or not
  # Neutral characters do not occur in legacy East Asian character sets.
  def self.neutral?(char : Char)
    neutral?(char.ord)
  end
end

require "./charwidth/*"
