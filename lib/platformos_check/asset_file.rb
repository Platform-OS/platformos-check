# frozen_string_literal: true

require "zlib"

module PlatformosCheck
  class AssetFile < AppFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/assets/|(app/)?modules/((\w|-)*)/(private|public)/assets/)}

    def initialize(relative_path, storage)
      super
      @loaded = false
      @content = nil
    end

    def rewriter
      @rewriter ||= AppFileRewriter.new(@relative_path, source)
    end

    def write
      content = rewriter.to_s
      return unless source != content

      @storage.write(@relative_path, content.gsub("\n", @eol))
      @source = content
      @rewriter = nil
    end

    def gzipped_size
      @gzipped_size ||= Zlib.gzip(source).bytesize
    end

    def dir_prefix
      DIR_PREFIX
    end

    def remove_extension(path)
      path
    end
  end
end
