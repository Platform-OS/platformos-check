# frozen_string_literal: true

module PlatformosCheck
  class LayoutFile < LiquidFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/(views/layouts)/|(app/)?modules/((\w|-)*)/(private|public)/(views/layouts)/)}

    def layout?
      true
    end

    def dir_prefix
      DIR_PREFIX
    end
  end
end
