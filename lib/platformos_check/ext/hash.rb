# frozen_string_literal: true

class Hash
  def deep_merge!(other_hash, &block)
    merge!(other_hash) do |key, this_val, other_val|
      if this_val.is_a?(Hash) && other_val.is_a?(Hash)
        this_val.deep_merge(other_val, &block)
      elsif block
        yield(key, this_val, other_val)
      else
        other_val
      end
    end
  end

  def deep_merge(other_hash, &)
    dup.deep_merge!(other_hash, &)
  end
end
