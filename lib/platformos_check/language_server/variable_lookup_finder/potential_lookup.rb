# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    module VariableLookupFinder
      class PotentialLookup < Struct.new(:name, :lookups, :scope, :file_path)
      end
    end
  end
end
