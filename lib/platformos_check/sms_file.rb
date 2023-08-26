# frozen_string_literal: true

module PlatformosCheck
  class SmsFile < LiquidFile
    def notification?
      true
    end
  end
end
