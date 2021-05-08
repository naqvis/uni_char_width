# Unicode Character & String Width

Shard Provides functionality to get fixed width of the unicode character or string.

For more information, refer to **EAST ASIAN WIDTH** [Unicode Standard Annex #11](http://unicode.org/reports/tr29/) (Unicode version 13.0.0).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     uniwidth:
       github: naqvis/uni_char_width
   ```

2. Run `shards install`

## Usage

Code try to identify the locale and set `east_asian` property accordingly. You can enforce the code to enable **CJK** mode by setting `EASTASIAN` environment variable to "1". `strict_emoji_neutral` property is enabled by default, but this should be set to `false` for broken Fonts.

Module `UnicodeCharWidth` provided methods uses the default settings (stated above), if you need to tweak the settings, instantiate an instance of `UnicodeCharWidth::Condition` class with respective settings.
```crystal
require "uniwidth"

# String/Char width
pp UnicodeCharWidth.width("つのだ☆HIRO") # => 12 on CJK locale

# Truncate
pp UnicodeCharWidth.truncate("つのだ☆HIRO",10,"...") # => "つのだ..."

# Padding
pp UnicodeCharWidth.pad_left("あxいうえお", 15) # => "    あxいうえお"
pp UnicodeCharWidth.pad_right("あxいうえお", 15) # => "あxいうえお    "

...
```

Refer to `specs` for more examples.

## Development

To run all tests:

```
crystal spec
```

## Contributing

1. Fork it (<https://github.com/naqvis/uni_char_width/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ali Naqvi](https://github.com/naqvis) - creator and maintainer
