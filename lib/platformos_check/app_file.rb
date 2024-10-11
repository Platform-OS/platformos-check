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
      @name ||= dir_prefix.nil? ? remove_extension(relative_path).to_s : build_name
    end

    def remove_extension(path)
      path.sub_ext('')
    end

    def build_name
      n = remove_extension(relative_path.sub(dir_prefix, '')).to_s
      return n if module_name.nil?

      return n if n.start_with?(module_prefix)

      "#{module_prefix}#{n}"
    end

    def dir_prefix
      nil
    end

    def module_prefix
      @module_prefix ||= "modules#{File::SEPARATOR}#{module_name}#{File::SEPARATOR}"
    end

    def module_name
      @module_name ||= if module_original_file?
                         dir_names[1]
                       elsif module_overwrite_file?
                         return dir_names[2]
                       end
    end

    def module_original_file?
      dir_names[0] == 'modules'
    end

    def module_overwrite_file?
      dir_names[0] == 'app' && dir_names[1] == 'modules'
    end

    def module_overwrite_file_path
      @module_overwrite_file_path ||= module_original_file? ? 'app/' + relative_path.to_s : nil
    end

    def module_original_file_path
      @module_original_file_path ||= module_overwrite_file? ? dir_names[1..].join(File::SEPARATOR) : nil
    end

    def dir_names
      @dir_names ||= @relative_path.split(File::SEPARATOR).reject(&:empty?)
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

    def graphql?
      false
    end

    def page?
      false
    end

    def partial?
      false
    end

    def translation?
      false
    end

    def ==(other)
      other.is_a?(self.class) && relative_path == other.relative_path
    end
    alias eql? ==
  end
end
