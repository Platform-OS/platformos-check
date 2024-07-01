# HTML Check API

This API is designed for checking HTML elements within `.liquid` files.

To check HTML tags or attributes, use the `HtmlCheck` class. 

HTML content in Liquid files is parsed using Nokogiri, which results in each element being represented as a [`Nokogiri::XML::Node`][nokogiri].

```ruby
module PlatformosCheck
  class MyCheckName < HtmlCheck
    category :html,
    # A check can belong to multiple categories. Valid categories are:
    categories :translation, :performance
    severity :suggestion # :error or :style

    def on_document(node)
      # Called with the root node of all theme files.
      node.value      # returns the value of the node, an instance of Nokogiri::XML::Node.
      node.app_file # points to the HTML file being analyzed. See lib/platformos_check/app_file.rb.
      node.parent     # is the parent node.
      node.children   # are the child nodes.
      # Additional helper methods are available in lib/platformos_check/html_node.rb.
      theme # Gives you access to all the theme files in the theme. See lib/platformos_check/app.rb.
    end

    def on_img(node)
      # Called for every <img> element in the file.
      node.attributes["class"] # Retrieves the 'class' attribute of the <img> tag.
    end

    def on_a(node)
      # Called for every <a> element in the file.
    end
  end
end
```

## Resources

- [Nokogiri::XML::Node API doc][nokogiri]

[nokogiri]: https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node


