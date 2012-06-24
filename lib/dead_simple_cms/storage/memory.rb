module DeadSimpleCMS
  module Storage
    # Public: Only used for testing and test-driving purposes. Once your application shutdown, you will lose the CMS information
    class Memory < Base

      @@cache = {}

      private

      def read_value
        @@cache[unique_key]
      end

      def write_value(value)
        @@cache[unique_key] = value
      end

    end
  end
end