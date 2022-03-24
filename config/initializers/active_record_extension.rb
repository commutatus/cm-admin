ActiveSupport.on_load(:active_record) do
  module ActiveRecord
    class Base
      def self.cm_admin(&block)
        CmAdmin.initialize_model(self, &block)
      end
    end
  end
end
