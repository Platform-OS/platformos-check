# frozen_string_literal: true

module PlatformosCheck
  # Reports errors when invalid tags are used in a Theme App
  # Extension block
  class AppBlockValidTags < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    # Don't allow this check to be disabled with a comment,
    # since we need to be able to enforce this server-side
    can_disable false

    OFFENSE_MSG = "Theme app extension blocks cannot contain %s tags"

    def on_javascript(node)
      add_offense(OFFENSE_MSG % 'javascript', node:)
    end

    def on_stylesheet(node)
      add_offense(OFFENSE_MSG % 'stylesheet', node:)
    end

    def on_background(node)
      add_offense(OFFENSE_MSG % 'background', node:)
    end

    def on_include(node)
      add_offense(OFFENSE_MSG % 'include', node:)
    end

    def on_layout(node)
      add_offense(OFFENSE_MSG % 'layout', node:)
    end

    def on_section(node)
      add_offense(OFFENSE_MSG % 'section', node:)
    end

    def on_sections(node)
      add_offense(OFFENSE_MSG % 'sections', node:)
    end
  end
end
