module DeadSimpleCMS
  module Storage
    class Redis < Base
      class << self
        attr_writer :connection
        def connection
          @connection ||= (defined?(REDIS) && REDIS) || raise(NotImplementedError, "Redis connection not set.")
        end
      end

      private

      def read_value
        self.class.connection.get(unique_key)
      end

      def write_value(value)
        self.class.connection.set(unique_key, value)
      end

    end
  end
end