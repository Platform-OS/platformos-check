# frozen_string_literal: true

module PlatformosCheck
  class FormFile < LiquidFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/(form_configurations|forms)/|modules/((\w|-)*)/(private|public)/(form_configurations|forms)/)}

    def form?
      true
    end

    def dir_prefix
      DIR_PREFIX
    end
  end
end
