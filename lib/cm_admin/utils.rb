module CmAdmin::Utils
  class << self
    def serialize_csv_columns(*columns, **hashes)
      # Turns an arbitrary list of args and kwargs into a list of params to be used in a form
      # For example, turns CmAdmin::Utils.serialize_csv_columns(:a, :b, c: [:d, e: :h], f: :g)
      # into [:a, :b, "c/d", "c/e/h", "f/g"]
      columns.map(&:to_s) + hashes.map do |key, value|
        serialize_csv_columns(*value).map do |column|
          "#{key}/#{column}"
        end
      end.reduce([], :+)
    end

    def deserialize_csv_columns(list, method)
      # Does the opposite operation of serialize_csv_columns
      list.reduce(recursive_hash) do |acc, item|
        tokens = item.to_s.split('/')
        send(method, acc, tokens.shift, tokens)
      end
    end

    def recursive_hash
      func = ->(h, k) { h[k] = Hash.new(&func) }
      # This hash creates a new hash, infinitely deep, whenever a value is not found
      # recursive_hash[:a][:b][:c][:d] will never fail
      Hash.new(&func)
    end

    def as_json_params(hash, key, tokens)
      hash.empty? && hash = { only: [], methods: [], include: recursive_hash }
      if tokens.empty?
        # base case
        hash[:methods] << key
      else
        # recursive case
        # hash[:associations] ||= {}
        hash[:include][key] = as_json_params(hash[:include][key], tokens.shift, tokens)
      end
      hash
    end

    def flatten_hash(hash, prefix="", separator="_")
      hash.reduce({}) do |acc, item|
        case item[1]
        when Hash
          acc.merge(flatten_hash(item[1], "#{prefix}#{item[0]}#{separator}"))
        else
          acc.merge("#{prefix}#{item[0]}" => item[1])
        end
      end
    end

    def base(hash, key, tokens) # recursive
      hash.empty? && hash = { columns: [], associations: recursive_hash }
      if tokens.empty?
        # base case
        hash[:columns] << key
      else
        # recursive case
        # hash[:associations] ||= {}
        hash[:associations][key] = base(hash[:associations][key], tokens.shift, tokens)
      end
      hash
    end

  end
end
