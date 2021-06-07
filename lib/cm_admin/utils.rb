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

  end
end
