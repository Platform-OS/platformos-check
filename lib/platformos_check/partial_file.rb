# frozen_string_literal: true

module PlatformosCheck
  class PartialFile < LiquidFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/(views/partials|liquid_views|views|lib)/|modules/((\w|-)*)/(private|public)/(views/partials|liquid_views|views|lib)/)}

    def partial?
      true
    end

    def name
      @name ||= build_name
    end

    private

    def build_name
      n = relative_path.sub(DIR_PREFIX, '').sub_ext('').to_s
      return n if module_name.nil?

      prefix = "modules#{File::SEPARATOR}#{module_name}#{File::SEPARATOR}"
      return n if n.start_with?(prefix)

      "#{prefix}#{n}"
    end
  end
end
