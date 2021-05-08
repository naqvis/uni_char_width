require "./spec_helper"

struct CharWdthSpec < ASPEC::TestCase
  @c : UnicodeCharWidth::Condition

  def initialize
    @c = UnicodeCharWidth::Condition.new(false)
  end

  @[DataProvider("width_tests_data")]
  def test_width_without_east_asian(*tc)
    wid = @c.width(tc.first)
    wid.should eq(tc[1]), "Char width(#{tc.first}) = #{wid}, want #{tc[1]} (east_asian = false)"
  end

  @[DataProvider("width_tests_data")]
  def test_width_with_east_asian(*tc)
    @c.east_asian = true
    wid = @c.width(tc.first)
    wid.should eq(tc[2]), "Char width(#{tc.first}) = #{wid}, want #{tc[2]} (east_asian = true)"
  end

  @[DataProvider("width_tests_data")]
  def test_width_without_strict_emoji_neutral(*tc)
    @c.east_asian = true
    @c.strict_emoji_neutral = false
    wid = @c.width(tc.first)
    wid.should eq(tc[3]), "Char width(#{tc.first}) = #{wid}, want #{tc[3]} (strict_emoji_neutral = false)"
  end

  @[DataProvider("ambiguous_data")]
  def test_ambiguous?(*tc)
    UnicodeCharWidth.ambiguous?(tc.first).should eq(tc[1])
  end

  @[DataProvider("string_width_data")]
  def test_string_width_without_east_asian(*tc)
    wid = @c.width(tc.first)
    wid.should eq(tc[1]), "String width(#{tc.first}) = #{wid}, want #{tc[1]} (east_asian = false)"
  end

  @[DataProvider("string_width_data")]
  def test_string_width_with_east_asian(*tc)
    @c.east_asian = true
    wid = @c.width(tc.first)
    wid.should eq(tc[2]), "String width(#{tc.first}) = #{wid}, want #{tc[2]} (east_asian = true)"
  end

  def test_string_width_with_invalid_char
    UnicodeCharWidth.width("こんにちわ\u{0}世界").should eq(14)
  end

  def test_truncate_smaller
    s = "あいうえお"
    expected = "あいうえお"
    got = UnicodeCharWidth.truncate(s, 10, "...")
    got.should eq(expected)
  end

  def test_truncate
    s = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
    expected = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおお..."
    got = UnicodeCharWidth.truncate(s, 80, "...")
    got.should eq(expected)
    wid = UnicodeCharWidth.width(got)
    wid.should eq(79)
  end

  def test_tuncate_fit
    s = "aあいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
    expected = "aあいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおお..."
    got = UnicodeCharWidth.truncate(s, 80, "...")
    got.should eq(expected)
    wid = UnicodeCharWidth.width(got)
    wid.should eq(80)
  end

  def test_wrap
    s = <<-TXT
    東京特許許可局局長はよく柿喰う客だ/東京特許許可局局長はよく柿喰う客だ
    123456789012345678901234567890

    END
    TXT
    expected = <<-TXT
  東京特許許可局局長はよく柿喰う
  客だ/東京特許許可局局長はよく
  柿喰う客だ
  123456789012345678901234567890

  END
  TXT

    got = UnicodeCharWidth.wrap(s, 30)
    got.should eq(expected)
  end

  @[DataProvider("neutral_data")]
  def test_neutral?(*tc)
    UnicodeCharWidth.neutral?(tc.first).should eq(tc[1])
  end

  def test_pad_left
    s = "あxいうえお"
    expected = "    あxいうえお"
    got = UnicodeCharWidth.pad_left(s, 15)
    got.should eq(expected)
  end

  def test_pad_left_fit
    s = "あxいうえお"
    expected = "あxいうえお"
    got = UnicodeCharWidth.pad_left(s, 10)
    got.should eq(expected)
  end

  def test_pad_right
    s = "あxいうえお"
    expected = "あxいうえお    "
    got = UnicodeCharWidth.pad_right(s, 15)
    got.should eq(expected)
  end

  def test_pad_right_fit
    s = "あxいうえお"
    expected = "あxいうえお"
    got = UnicodeCharWidth.pad_right(s, 10)
    got.should eq(expected)
  end

  @[DataProvider("joiner_data")]
  def test_zero_width_joiner(*tc)
    UnicodeCharWidth.width(tc.first).should eq(tc[1])
  end

  def width_tests_data : Array
    [
      {'世', 2, 2, 2},
      {'界', 2, 2, 2},
      {'ｾ', 1, 1, 1},
      {'ｶ', 1, 1, 1},
      {'ｲ', 1, 1, 1},
      {'☆', 1, 2, 2}, # double width in ambiguous
      {'☺', 1, 1, 2},
      {'☻', 1, 1, 2},
      {'♥', 1, 2, 2},
      {'♦', 1, 1, 2},
      {'♣', 1, 2, 2},
      {'♠', 1, 2, 2},
      {'♂', 1, 2, 2},
      {'♀', 1, 2, 2},
      {'♪', 1, 2, 2},
      {'♫', 1, 1, 2},
      {'☼', 1, 1, 2},
      {'↕', 1, 2, 2},
      {'‼', 1, 1, 2},
      {'↔', 1, 2, 2},
      {'\u{0}', 0, 0, 0},
      {'\u{01}', 0, 0, 0},
      {'\u0300', 0, 0, 0},
      {'\u2028', 0, 0, 0},
      {'\u2029', 0, 0, 0},
      {'a', 1, 1, 1}, # ASCII classified as "na" (narrow)
      {'⟦', 1, 1, 1}, # non-ASCII classified as "na" (narrow)
      {'👁', 1, 1, 2},
    ]
  end

  def ambiguous_data : Array
    [
      {'世', false},
      {'■', true},
      {'界', false},
      {'○', true},
      {'㈱', false},
      {'①', true},
      {'②', true},
      {'③', true},
      {'④', true},
      {'⑤', true},
      {'⑥', true},
      {'⑦', true},
      {'⑧', true},
      {'⑨', true},
      {'⑩', true},
      {'⑪', true},
      {'⑫', true},
      {'⑬', true},
      {'⑭', true},
      {'⑮', true},
      {'⑯', true},
      {'⑰', true},
      {'⑱', true},
      {'⑲', true},
      {'⑳', true},
      {'☆', true},
    ]
  end

  def neutral_data : Array
    [
      {'→', false},
      {'┊', false},
      {'┈', false},
      {'～', false},
      {'└', false},
      {'⣀', true},
      {'⣀', true},
    ]
  end

  def joiner_data : Array
    [
      {"👩", 2},
      {"👩‍", 2},
      {"👩‍🍳", 2},
      {"‍🍳", 2},
      {"👨‍👨", 2},
      {"👨‍👨‍👧", 2},
      {"🏳️‍🌈", 1},
      {"あ👩‍🍳い", 6},
      {"あ‍🍳い", 6},
      {"あ‍い", 4},
    ]
  end

  def string_width_data : Array
    [
      {"■㈱の世界①", 10, 12},
      {"スター☆", 7, 8},
      {"つのだ☆HIRO", 11, 12},
    ]
  end
end
