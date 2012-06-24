module DeadSimpleCMS
  module Storage
    # Public: Store all the values in whatever is defined for the rails cache.
    # Does not support storage of data with the value (ie no file storage support).
    class RailsCache < Base

      private

      def read_value
        ::Rails.cache.read(unique_key)
      end

      def write_value(value)
        ::Rails.cache.write(unique_key, value, :expires_in => 5.years.from_now) # some really long time
      end

    end
  end
end