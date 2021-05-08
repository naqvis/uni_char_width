require "textseg"

require "./eastasian"
require "./table"

module UnicodeCharWidth
  # DefaultCondition is a condition in current locale
  class_getter(default_condition) { Condition.new }

  class Condition
    # Will be set to true if the current locale is CJK
    property east_asian : Bool
    # should be set to false if handle broken fonts
    property strict_emoji_neutral : Bool

    def initialize(@east_asian = Condition.handle_env, @strict_emoji_neutral = true)
    end

    # returns the number of cells in codepoint
    # see http://www.unicode.org/reports/tr11/
    def width(codepoint : Int32)
      if !east_asian
        case
        when codepoint < 0x20 || codepoint > 0x10FFFF then 0
        when (codepoint >= 0x7F && codepoint <= 0x9F) || codepoint == 0xAD # NonPrint
          0
        when codepoint < 0x300                                           then 1
        when in_table?(codepoint, UnicodeCharWidth.narrow)               then 1
        when in_tables?(codepoint, NonPrint, UnicodeCharWidth.combining) then 0
        when in_table?(codepoint, UnicodeCharWidth.doublewidth)          then 2
        else                                                                  1
        end
      else
        case
        when codepoint < 0 || codepoint > 0x10FFFF ||
          in_tables?(codepoint, NonPrint, UnicodeCharWidth.combining)
          0
        when in_table?(codepoint, UnicodeCharWidth.narrow)
          1
        when in_tables?(codepoint, UnicodeCharWidth.ambiguous, UnicodeCharWidth.doublewidth)
          2
        when !strict_emoji_neutral &&
          in_tables?(codepoint, UnicodeCharWidth.ambiguous,
            UnicodeCharWidth.emoji, UnicodeCharWidth.narrow)
          2
        else
          1
        end
      end
    end

    # return the number of cells in `char'
    def width(char : Char)
      width(char.ord)
    end

    # returns string width
    def width(str : String)
      res = 0
      TextSegment.graphemes(str).each do |cluster|
        chw = 0
        cluster.codepoints.each do |cp|
          chw = width(cp)
          break if chw > 0 # Our best guess at this point is to use the width of the first non-zero-width char
        end
        res += chw
      end
      res
    end

    # return string truncated with `w` cells
    def truncate(str : String, w : Int32, tail : String)
      return str if width(str) <= w

      w -= width(tail)
      sw = 0
      pos = str.bytesize
      TextSegment.graphemes(str).each do |cluster|
        chw = 0
        cluster.codepoints.each do |cp|
          chw = width(cp)
          break if chw > 0
        end
        if sw + chw > w
          pos, _ = cluster.positions
          break
        end
        sw += chw
      end
      String.new(str.to_slice[...pos]) + tail
    end

    # returns a string wrapped with `w` cells
    def wrap(str : String, w : Int32)
      wid = 0
      String.build do |sb|
        str.codepoints.each do |r|
          cw = width(r)
          if r.chr.in?(NEW_LINE)
            sb << r.chr
            wid = 0
            next
          elsif wid + cw > w
            sb << NEW_LINE
            wid = 0
            sb << r.chr
            wid += cw
            next
          end
          sb << r.chr
          wid += cw
        end
      end
    end

    # returns a string filled in left by spaces in `w` cells
    def pad_left(str : String, w : Int32)
      wid = width(str)
      cnt = w - wid
      if cnt > 0
        b = Bytes.new(cnt, ' '.ord.to_u8)
        return String.new(b) + str
      end
      str
    end

    # returns a string filled in right by spaces in `w` cells
    def pad_right(str : String, w : Int32)
      wid = width(str)
      cnt = w - wid
      if cnt > 0
        b = Bytes.new(cnt, ' '.ord.to_u8)
        return str + String.new(b)
      end
      str
    end

    # returns whether is ambiguous width or not
    def ambiguous?(codepoint : Int32)
      in_tables?(codepoint, Private, UnicodeCharWidth.ambiguous)
    end

    # returns whether is neutral width or not
    def neutral?(codepoint : Int32)
      in_table?(codepoint, UnicodeCharWidth.neutral)
    end

    private def in_tables?(code, *ts)
      ts.each do |t|
        return true if in_table?(code, t)
      end
      false
    end

    private def in_table?(code, table)
      return false if code < table[0].first
      bot = 0
      top = table.size - 1
      while top >= bot
        mid = (bot + top) >> 1
        case
        when table[mid].last < code  then bot = mid + 1
        when table[mid].first > code then top = mid - 1
        else
          return true
        end
      end
      false
    end

    # :nodoc:
    protected def self.handle_env
      env = ENV["EASTASIAN"]? || ""
      env.blank? ? UnicodeCharWidth.east_asian? : env == "1"
    end

    private Private = [
      {0x00E000, 0x00F8FF}, {0x0F0000, 0x0FFFFD}, {0x100000, 0x10FFFD},
    ]

    private NonPrint = [
      {0x0000, 0x001F}, {0x007F, 0x009F}, {0x00AD, 0x00AD},
      {0x070F, 0x070F}, {0x180B, 0x180E}, {0x200B, 0x200F},
      {0x2028, 0x202E}, {0x206A, 0x206F}, {0xD800, 0xDFFF},
      {0xFEFF, 0xFEFF}, {0xFFF9, 0xFFFB}, {0xFFFE, 0xFFFF},
    ]
  end
end
