# frozen_string_literal: true

module PlatformosCheck
  class Storage
    def path(relative_path)
      raise NotImplementedError
    end

    def read(relative_path)
      raise NotImplementedError
    end

    def write(relative_path, content)
      raise NotImplementedError
    end

    def files
      raise NotImplementedError
    end

    def platformos_app
      @platformos_app ||= PlatformosCheck::App.new(self)
    end

    def versioned?
      false
    end
  end
end
