# Liquid Check API

This API is designed to check Liquid code in `.liquid` files.

All code inside `{% ... %}` or `{{ ... }}` is Liquid code, and liquid files are parsed using the Liquid parser. This parsing process converts the code into Liquid nodes, such as tags and blocks, which are then used in your callback methods. For a deeper understanding of these nodes, refer to the [Liquid source][liquidsource].

```ruby
module PlatformosCheck
  class MyCheckName < LiquidCheck
    category :liquid,
    # A check can belong to multiple categories. Valid categories are:
    categories :translation, :performance
    severity :suggestion # :error or :style

    def on_document(node)
      # Called with the root node of all liquid_file.
      node.value      # is the original Liquid object for this node. See Liquid source code for details.
      node.app_file # is the liquid_file being analyzed. See lib/platformos_check/liquid_file.rb.
      node.parent     # is the parent node.
      node.children   # are the child nodes.
      # Additional helper methods are available in lib/platformos_check/node.rb.
      theme # Gives you access to all the theme files in the theme. See lib/platformos_check/theme.rb.
    end

    def on_node(node)
      # Called for every node.
    end

    def on_tag(node)
      # Called for each tag (if, include, for, assign, etc.).
    end

    def after_tag(node)
      # Called after visiting the children of a tag.

      # If you find an issue, add an offense:
      add_offense("Describe the problem...", node: node)
      # Or, if the offense is related to the whole theme file:
      add_offense("Describe the problem...", app_file: node.app_file)
    end

    def on_assign(node)
      # Specifically for {% assign ... %} tags.
    end

    def on_string(node)
      # Called for every `String`, including those within if conditions.
      if node.parent.block?
        # If the parent is a block, `node.value` is a String written directly to the output when the theme file is rendered.
      end
    end

    def on_variable(node)
      # Called for each {{ ... }}
    end

    def on_error(exception)
      # Called each time a Liquid exception is raised while parsing the theme file.
    end

    def on_end
      # A special callback after we're done visiting all the files of the theme.
    end

    # Each type of node has a corresponding `on_node_class_name` & `after_node_class_name`
    # A few common examples:
    # on_background(node)
    # on_cache(node)
    # on_capture(node)
    # on_case(node)
    # on_comment(node)
    # on_condition(node)
    # on_content_for(node)
    # on_else_condition(node)
    # on_export(node)
    # on_for(node)
    # on_form(node)
    # on_function(node)
    # on_graphql(node)
    # on_if(node)
    # on_include(node)
    # on_integer(node)
    # on_log(node)
    # on_method_literal(node)
    # on_parse_json(node)
    # on_print(node)
    # on_range(node)
    # on_redirect_to(node)
    # on_render(node)
    # on_response_headers(node)
    # on_response_status(node)
    # on_return(node)
    # on_session(node)
    # on_sign_in(node)
    # on_spam_protection(node)
    # on_theme_render(node)
    # on_try(node)
    # on_unless(node)
    # on_variable_lookup(node)
    # on_yield(node)
  end
end
```

## Resources

- [platformOS Liquid][posliquid]
- [Liquid source][liquidsource]

[posliquid]: https://documentation.platformos.com/api-reference/liquid/introduction
[liquidsource]: https://github.com/Shopify/liquid/tree/master/lib/liquid
