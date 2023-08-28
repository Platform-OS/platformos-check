# frozen_string_literal: true

module PlatformosCheck
  class JsonHelper
    # Deeply sets a value in a hash. Accepts both arrays and strings for path.
    def self.set(hash, path, value)
      path = path.split('.') if path.is_a?(String)
      path.each_with_index.reduce(hash) do |pointer, (token, index)|
        if index == path.size - 1
          pointer[token] = value
        elsif !pointer.key?(token) || !pointer[token].is_a?(Hash)
          pointer[token] = {}
        end
        pointer[token]
      end
      hash
    end

    # Deeply delete a key from a hash
    def self.delete(hash, path)
      path = path.split('.') if path.is_a?(String)
      path.each_with_index.reduce(hash) do |pointer, (token, index)|
        break pointer.delete(token) if index == path.size - 1

        pointer[token]
      end
    end

    # Deeply add key/values inside a hash.
    #
    # Handles arrays by adding the key/value to all hashes inside the array.
    #
    # Specially handles objects that have the "id" key like this:
    #
    # e.g.
    #
    # json = {
    #   "deep" => [
    #     { "id" => "hi" },
    #     { "id" => "oh" },
    #   ],
    # }
    # assert_equal(
    #   {
    #     "deep" => [
    #       { "id" => "hi", "ho" => "ho" },
    #       { "id" => "oh" },
    #     ],
    #   },
    #   JsonHelper.json_corrector(json, "deep.hi.ho", "ho")
    # )
    def self.json_corrector(json, path, value)
      return json unless json.is_a?(Hash)

      path = path.split('.') if path.is_a?(String)
      path.each_with_index.reduce(json) do |pointer, (token, index)|
        case pointer
        when Array
          pointer.each do |item|
            json_corrector(item, path.drop(1), value)
          end

        when Hash
          break pointer[token] = value if index == path.size - 1

          pointer[token] = {} unless pointer.key?(token) || pointer.key?("id")
          pointer[token].nil? && pointer["id"] == token ? pointer : pointer[token]
        end
      end
      json
    end
  end
end
