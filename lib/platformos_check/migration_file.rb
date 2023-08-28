# frozen_string_literal: true

module PlatformosCheck
  class MigrationFile < LiquidFile
    def migration?
      true
    end
  end
end
