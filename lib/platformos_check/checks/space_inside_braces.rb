# frozen_string_literal: true

module PlatformosCheck
  # Ensure {% ... %} & {{ ... }} have consistent spaces.
  class SpaceInsideBraces < LiquidCheck
    severity :style
    category :liquid
    doc docs_url(__FILE__)

    def on_node(node)
      return unless node.markup
      return if node.literal?
      return if node.assigned_or_echoed_variable?

      outside_of_strings(node.markup) do |chunk, chunk_start|
        chunk.scan(/(?<token>[,:|]|==|<>|<=|>=|<|>|!=)(?<offense>  +)/) do |_match|
          add_too_many_spaces_after_offense(Regexp.last_match, node, chunk_start)
        end
        chunk.scan(/(?<offense>(?<token>[,:|]|==|<>|<=|>=|<\b|>\b|!=)(\S|\z))/) do |_match|
          add_space_missing_after_offense(Regexp.last_match, node, chunk_start)
        end
        chunk.scan(/(?<offense>\s{2,})(?<token>\||==|<>|<=|>=|<|>|!=)+/) do |_match|
          add_too_many_spaces_before_offense(Regexp.last_match, node, chunk_start) unless Regexp.last_match(:offense).include?("\n")
        end
        chunk.scan(/(\A|\S)(?<offense>(?<token>\||==|<>|<=|>=|<|\b>|!=))/) do |_match|
          add_space_missing_before_offense(Regexp.last_match, node, chunk_start)
        end
      end
    end

    BlockMarkup = Struct.new(:markup, :node_markup_offset)

    def on_tag(node)
      return if node.inside_liquid_tag?

      # Both the start and end tags
      blocks = [
        BlockMarkup.new(node.block_start_markup, node.block_start_start_index - node.start_index),
        BlockMarkup.new(node.block_end_markup, node.block_end_start_index - node.start_index)
      ]

      blocks.each do |block|
        # Looking at spaces after the start token
        add_space_missing_after_offense(Regexp.last_match, node, block.node_markup_offset) if block.markup =~ /^(?<token>{%-?)(?<offense>[^ \n\t-])/

        add_too_many_spaces_after_offense(Regexp.last_match, node, block.node_markup_offset) if block.markup =~ /^(?<token>{%-?)(?<offense> {2,})\S/

        # Looking at spaces before the end token
        add_space_missing_before_offense(Regexp.last_match, node, block.node_markup_offset) if block.markup =~ /(?<offense>[^ \n\t-])(?<token>-?%})$/

        add_too_many_spaces_before_offense(Regexp.last_match, node, block.node_markup_offset) if block.markup =~ /\S(?<offense> {2,})(?<token>-?%})$/

        next
      end
    end

    def on_variable(node)
      return if node.markup.empty?
      return if node.assigned_or_echoed_variable?

      block_start_offset = node.block_start_start_index - node.start_index

      # Looking at spaces after the start token
      add_space_missing_after_offense(Regexp.last_match, node, block_start_offset) if node.block_start_markup =~ /^(?<token>{{-?)(?<offense>[^ \n\t-])/

      add_too_many_spaces_after_offense(Regexp.last_match, node, block_start_offset) if node.block_start_markup =~ /^(?<token>{{-?)(?<offense> {2,})\S/

      # Looking at spaces before the end token
      add_space_missing_before_offense(Regexp.last_match, node, block_start_offset) if node.block_start_markup =~ /(?<offense>[^ \n\t-])(?<token>-?}})$/

      return unless node.block_start_markup =~ /\S(?<offense> {2,})(?<token>-?}})$/

      add_too_many_spaces_before_offense(Regexp.last_match, node, block_start_offset)
    end

    def add_space_missing_after_offense(match, node, source_offset)
      add_offense_for_match(
        "Space missing after '#{match[:token]}'",
        match,
        node,
        source_offset
      ) do |corrector|
        corrector.insert_after(
          node,
          ' ',
          (node.start_index + source_offset + match.begin(:token))...
          (node.start_index + source_offset + match.end(:token))
        )
      end
    end

    def add_too_many_spaces_after_offense(match, node, source_offset)
      add_offense_for_match(
        "Too many spaces after '#{match[:token]}'",
        match,
        node,
        source_offset
      ) do |corrector|
        corrector.replace(
          node,
          ' ',
          (node.start_index + source_offset + match.begin(:offense))...
          (node.start_index + source_offset + match.end(:offense))
        )
      end
    end

    def add_space_missing_before_offense(match, node, source_offset)
      add_offense_for_match(
        "Space missing before '#{match[:token]}'",
        match,
        node,
        source_offset
      ) do |corrector|
        corrector.insert_before(
          node,
          ' ',
          (node.start_index + source_offset + match.begin(:token))...
          (node.start_index + source_offset + match.end(:token))
        )
      end
    end

    def add_too_many_spaces_before_offense(match, node, source_offset)
      add_offense_for_match(
        "Too many spaces before '#{match[:token]}'",
        match,
        node,
        source_offset
      ) do |corrector|
        corrector.replace(
          node,
          ' ',
          (node.start_index + source_offset + match.begin(:offense))...
          (node.start_index + source_offset + match.end(:offense))
        )
      end
    end

    def add_offense_for_match(message, match, node, source_offset, &)
      add_offense(
        message,
        node:,
        markup: match[:offense],
        node_markup_offset: source_offset + match.begin(:offense),
        &
      )
    end
  end
end
