module CmAdmin
  class VersionManager
    class << self
      def rails6?
        Rails::VERSION::MAJOR == 6
      end

      def rails7?
        Rails::VERSION::MAJOR == 7
      end

      def use_importmap?
        rails7? && File.exist?('config/importmap.rb')
      end

      def use_webpacker?
        rails6? && defined?(Webpacker) == 'constant'
      end
    end
  end
end
