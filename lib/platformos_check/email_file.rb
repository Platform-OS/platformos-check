# frozen_string_literal: true

module PlatformosCheck
  class EmailFile < LiquidFile
    def notification?
      true
    end
  end
end
