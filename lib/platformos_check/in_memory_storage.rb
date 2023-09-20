# frozen_string_literal: true

# An in-memory storage is not written to disk. The reasons why you'd
# want to do that are your own. The idea is to not write to disk
# something that doesn't need to be there. If you have your platformos_app
# as a big hash already, leave it like that and save yourself some IO.
module PlatformosCheck
  class InMemoryStorage < Storage
    attr_reader :root

    def initialize(files = {}, root = "/dev/null")
      @files = files # Hash<String, String>
      @root = Pathname.new(root)
    end

    def path(relative_path)
      @root.join(relative_path)
    end

    def read(relative_path)
      @files[relative_path]
    end

    def write(relative_path, content)
      @platformos_app&.update([relative_path])
      @files[relative_path] = content
    end

    def remove(relative_path)
      @platformos_app&.update([relative_path], remove: true)
      @files.delete(relative_path)
    end

    def mkdir(relative_path)
      @files[relative_path] = nil
    end

    def files
      @files.keys
    end

    def files_with_content
      @files
    end

    def relative_path(absolute_path)
      Pathname.new(absolute_path).relative_path_from(@root).to_s
    end
  end
end
