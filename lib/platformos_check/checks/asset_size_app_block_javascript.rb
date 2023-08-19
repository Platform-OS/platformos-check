# frozen_string_literal: true

module PlatformosCheck
  # Reports errors when too much JS is being referenced from a App
  # Extension block
  class AssetSizeAppBlockJavaScript < LiquidCheck
    severity :error
    category :performance
    doc docs_url(__FILE__)

    # Don't allow this check to be disabled with a comment,
    # since we need to be able to enforce this server-side
    can_disable false

    attr_reader :threshold_in_bytes

    def initialize(threshold_in_bytes: 10_000)
      @threshold_in_bytes = threshold_in_bytes
    end

    def on_schema(node)
      schema = node.inner_json
      return if schema.nil?

      return unless (javascript = schema["javascript"])

      size = asset_size(javascript)
      return unless size && size > threshold_in_bytes

      add_offense(
        "JavaScript in App Extension blocks exceeds compressed size threshold (#{threshold_in_bytes} Bytes)",
        node:
      )
    end

    private

    def asset_size(name)
      asset = @platformos_app["assets/#{name}"]
      return if asset.nil?

      asset.gzipped_size
    end
  end
end
