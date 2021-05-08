# This script generates the file src/charwidth/table.cr
# that contains compact representations of the EastAsianWidth.txt and emoji-data.txt
# file from the unicode specification.

require "http/client"
require "ecr"
require "compiler/crystal/formatter"

record RRange, low : Int32, high : Int32

UCD_ROOT = "http://www.unicode.org/Public/13.0.0/ucd/"

def shapeup(arr)
  i = 0
  to_del = Array(Int32).new
  while i < arr.size - 1
    if arr[i].high + 1 == arr[i + 1].low
      low = arr[i].low
      to_del << i
      arr.delete_at(i)
      arr[i] = RRange.new(low, arr[i].high)
      # arr[i + 1] = RRange.new(low, arr[i + 1].high)
      # arr.delete_at(i)
      i -= 1
    end
    i += 1
  end
  arr
end

def eastasian(body, combining, doublewidth, ambiguous, narrow, neutral)
  body.each_line do |line|
    line = line.strip
    next if line.empty?
    next if line.starts_with?('#')

    data = line.split.first.split(';')
    fields = data.first.split("..")
    prop = data[1]
    f1 = fields.first.to_i(16)
    f2 = fields.size > 1 ? fields[1].to_i(16) : f1

    combining << RRange.new(f1, f2) if line.includes?("COMBINING")
    case prop
    when "W", "F" then doublewidth << RRange.new(f1, f2)
    when "A"      then ambiguous << RRange.new(f1, f2)
    when "Na"     then narrow << RRange.new(f1, f2)
    when "N"      then neutral << RRange.new(f1, f2)
    end
  end
  combining = shapeup(combining)
  doublewidth = shapeup(doublewidth)
  ambiguous = shapeup(ambiguous)
  narrow = shapeup(narrow)
  neutral = shapeup(neutral)
end

def parse_emoji(body, emoji)
  extended = false
  body.each_line do |line|
    line = line.strip
    next if line.empty?
    unless extended
      extended = line.ends_with?("Extended_Pictographic ; No")
      next unless extended
    end
    next if line.starts_with?('#')

    data = line.split.first.split(';')
    fields = data.first.split("..")
    f1 = fields.first.to_i(16)
    f2 = fields.size > 1 ? fields[1].to_i(16) : f1
    next if f2 < 0xFF
    emoji << RRange.new(f1, f2)
  end
  emoji = shapeup(emoji)
end

doublewidth = Array(RRange).new
ambiguous = Array(RRange).new
combining = Array(RRange).new
narrow = Array(RRange).new
neutral = Array(RRange).new
emoji = Array(RRange).new

body = HTTP::Client.get("#{UCD_ROOT}EastAsianWidth.txt").body
eastasian(body, combining, doublewidth, ambiguous, narrow, neutral)

body = HTTP::Client.get("#{UCD_ROOT}emoji/emoji-data.txt").body
parse_emoji(body, emoji)

output = String.build do |str|
  ECR.embed "#{__DIR__}/char_width_table.ecr", str
end
output = Crystal.format(output)
File.write("#{__DIR__}/../src/charwidth/table.cr", output)
