# YAML Check API

This API is designed for checking the content of `.yml` files.

```ruby
module PlatformosCheck
  class MyCheckName < YamlCheck
    category :yaml,
    # A check can belong to multiple categories. Valid categories are:
    categories :translation, :performance
    severity :suggestion # :error or :style

    def on_file(file)
      file # an instance of `PlatformosCheck::JsonFile`
      file.content # the parsed JSON, as a Ruby object, usually a Hash
    end
  end
end
```
