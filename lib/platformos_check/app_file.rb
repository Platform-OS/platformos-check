# frozen_string_literal: true

require "pathname"

module PlatformosCheck
  class AppFile
    attr_reader :version, :storage

    def initialize(relative_path, storage)
      @relative_path = relative_path
      @storage = storage
      @source = nil
      @version = nil
      @eol = "\n"
    end

    def path
      @storage.path(@relative_path)
    end

    def relative_path
      @relative_pathname ||= Pathname.new(@relative_path)
    end

    def name
      @name ||= dir_prefix.nil? ? relative_path.sub_ext('').to_s : build_name
    end

    def build_name
      n = relative_path.sub(dir_prefix, '').sub_ext('').to_s
      return n if module_name.nil?

      prefix = "modules#{File::SEPARATOR}#{module_name}#{File::SEPARATOR}"
      return n if n.start_with?(prefix)

      "#{prefix}#{n}"
    end

    def dir_prefix
      nil
    end

    def module_name
      @module_name ||= begin
        dir_names = @relative_path.split(File::SEPARATOR).reject(&:empty?)
        dir_names.first == 'modules' ? dir_names[1] : nil
      end
    end

    # For the corrector to work properly, we should have a
    # simple mental model of the internal representation of eol
    # characters (Windows uses \r\n, Linux uses \n).
    #
    # Parser::Source::Buffer strips the \r from the source file, so if
    # you are autocorrecting the file you might lose that info and
    # cause a git diff. It also makes the node.start_index/end_index
    # calculation break. That's not cool.
    #
    # So in here we track whether the source file has \r\n in it and
    # we'll make sure that the file we write has the same eol as the
    # source file.
    def source
      return @source if @source

      if @storage.versioned?
        @source, @version = @storage.read_version(@relative_path)
      else
        @source = @storage.read(@relative_path)
      end
      @eol = @source.include?("\r\n") ? "\r\n" : "\n"
      @source = @source
                .gsub(/\r(?!\n)/, "\r\n") # fix rogue \r without followup \n with \r\n
                .gsub("\r\n", "\n")
    end

    def yaml?
      false
    end

    def liquid?
      false
    end

    def ==(other)
      other.is_a?(self.class) && relative_path == other.relative_path
    end
    alias eql? ==
  end
end
