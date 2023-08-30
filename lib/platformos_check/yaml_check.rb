# frozen_string_literal: true

module PlatformosCheck
  class YamlCheck < Check
    extend ChecksTracking

    def add_offense(message, markup: nil, line_number: nil, app_file: nil, &block)
      offenses << Offense.new(check: self, message:, markup:, line_number:, app_file:, correction: block)
    end
  end
end
