module UnicodeCharWidth
  {% if flag?(:windows) %}
    NEW_LINE = "\r\n"

    lib LibC
      fun GetConsoleOutputCP : UInt32
    end

    # return true if the current locale is CJK
    def self.east_asian?
      r = LibC.GetConsoleOutputCP
      return false if r == 0
      [932, 936, 949, 950, 51932, 51936, 51949, 51950, 52936, 54936].includes?(r)
    end
  {% else %}
    NEW_LINE = "\n"

    # return true if the current locale is CJK
    def self.east_asian?
      locale = ENV["LC_ALL"]? || ENV["LC_CTYPE"]? || ENV["LANG"]? || ""
      return false if locale.empty? || ["POSIX", "C"].includes?(locale)

      return false if locale.size > 1 && locale[0] == 'C' && (locale[1] == '.' || locale[1] == '-')
      east_asian(locale)
    end

    private def self.east_asian(locale)
      charset = locale.downcase
      if (m = /^[a-z][a-z][a-z]?(?:_[A-Z][A-Z])?\.(.+)/.match(locale))
        charset = m[1].downcase if m.size == 2
      end

      return false if charset.ends_with?("@cjk_narrow")
      charset.chars.each_with_index do |c, i|
        if c == '@'
          charset = charset[...i]
          break
        end
      end
      ["utf-8", "utf8", "jis", "eucjp", "euckr", "euccn", "sjis", "cp932", "cp51932",
       "cp936", "cp949", "cp950", "big5", "gbk", "gb2312"].includes?(charset) &&
        (charset[0] != 'u' || locale.starts_with?("ja") || locale.starts_with?("ko") ||
          locale.starts_with?("zh"))
    end
  {% end %}
end
