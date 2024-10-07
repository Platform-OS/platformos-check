# frozen_string_literal: true

module PlatformosCheck
  class PartialFile < LiquidFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/(views/partials|liquid_views|views|lib)/|(app/)?modules/((\w|-)*)/(private|public)/(views/partials|liquid_views|views|lib)/)}

    def partial?
      true
    end

    def dir_prefix
      DIR_PREFIX
    end
  end
end
