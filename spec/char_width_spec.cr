require "./spec_helper"

describe UnicodeCharWidth do
  it "Test width" do
    tests = [
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
    c = UnicodeCharWidth::Condition.new(false)
    tests.each do |tc|
      wid = c.width(tc.first)
      fail "Char width(#{tc.first}) = #{wid}, want #{tc[1]} (east_asian = false)" unless wid == tc[1]
    end
    c.east_asian = true
    tests.each do |tc|
      wid = c.width(tc.first)
      fail "Char width(#{tc.first}) = #{wid}, want #{tc[2]} (east_asian = true)" unless wid == tc[2]
    end
    c.strict_emoji_neutral = false
    tests.each do |tc|
      wid = c.width(tc.first)
      fail "Char width(#{tc.first}) = #{wid}, want #{tc[3]} (strict_emoji_neutral = false)" unless wid == tc[3]
    end
  end

  it "Test ambiguous?" do
    tests = [
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

    tests.each do |tc|
      UnicodeCharWidth.ambiguous?(tc.first).should eq(tc[1])
    end
  end

  it "Test String width" do
    tests = [
      {"■㈱の世界①", 10, 12},
      {"スター☆", 7, 8},
      {"つのだ☆HIRO", 11, 12},
    ]
    c = UnicodeCharWidth::Condition.new(false)
    tests.each do |tc|
      wid = c.width(tc.first)
      fail "String width(#{tc.first}) = #{wid}, want #{tc[1]} (east_asian = false)" unless wid == tc[1]
    end
    c.east_asian = true
    tests.each do |tc|
      wid = c.width(tc.first)
      fail "String width(#{tc.first}) = #{wid}, want #{tc[2]} (east_asian = true)" unless wid == tc[2]
    end
  end

  it "Test String Width Invalid" do
    wid = UnicodeCharWidth.width("こんにちわ\u{0}世界")
    wid.should eq(14)
  end

  it "Test truncate smaller" do
    s = "あいうえお"
    expected = "あいうえお"
    got = UnicodeCharWidth.truncate(s, 10, "...")
    got.should eq(expected)
  end

  it "Test truncate smaller" do
    s = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
    expected = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおお..."
    got = UnicodeCharWidth.truncate(s, 80, "...")
    got.should eq(expected)
    wid = UnicodeCharWidth.width(got)
    wid.should eq(79)
  end

  it "Test truncate Fit" do
    s = "aあいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
    expected = "aあいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおお..."
    got = UnicodeCharWidth.truncate(s, 80, "...")
    got.should eq(expected)
    wid = UnicodeCharWidth.width(got)
    wid.should eq(80)
  end

  it "Test wrap" do
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

  it "Test neutral?" do
    tests = [
      {'→', false},
      {'┊', false},
      {'┈', false},
      {'～', false},
      {'└', false},
      {'⣀', true},
      {'⣀', true},
    ]

    tests.each do |tc|
      UnicodeCharWidth.neutral?(tc.first).should eq(tc[1])
    end
  end

  it "test pad_left" do
    s = "あxいうえお"
    expected = "    あxいうえお"
    got = UnicodeCharWidth.pad_left(s, 15)
    got.should eq(expected)
  end

  it "test pad_left Fit" do
    s = "あxいうえお"
    expected = "あxいうえお"
    got = UnicodeCharWidth.pad_left(s, 10)
    got.should eq(expected)
  end

  it "test pad_right" do
    s = "あxいうえお"
    expected = "あxいうえお    "
    got = UnicodeCharWidth.pad_right(s, 15)
    got.should eq(expected)
  end

  it "test pad_right Fit" do
    s = "あxいうえお"
    expected = "あxいうえお"
    got = UnicodeCharWidth.pad_right(s, 10)
    got.should eq(expected)
  end

  it "Test zero width joiner" do
    tests = [
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

    tests.each do |tc|
      UnicodeCharWidth.width(tc.first).should eq(tc[1])
    end
  end
end
