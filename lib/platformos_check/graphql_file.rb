# frozen_string_literal: true

module PlatformosCheck
  class GraphqlFile < AppFile
    def write
      content = rewriter.to_s
      return unless source != content

      @storage.write(@relative_path, content.gsub("\n", @eol))
      @source = content
      @rewriter = nil
    end

    def rewriter
      @rewriter ||= AppFileRewriter.new(@relative_path, source)
    end

    def source_excerpt(line)
      original_lines = source.split("\n")
      original_lines[bounded(0, line - 1, original_lines.size - 1)].strip
    rescue StandardError => e
      PlatformosCheck.bug(<<~EOS)
        Exception while running `source_excerpt(#{line})`:
        ```
        #{e.class}: #{e.message}
          #{e.backtrace.join("\n  ")}
        ```

        path: #{path}

        source:
        ```
        #{source}
        ```
      EOS
    end

    def parse
      @ast ||= self.class.parse(source)
    end

    def warnings
      @ast.warnings
    end

    def root
      parse.root
    end

    def self.parse(_source)
      Struct.new(:warnings, :root)
    end

    private

    def bounded(lower, x, upper)
      [lower, [x, upper].min].max
    end
  end
end
