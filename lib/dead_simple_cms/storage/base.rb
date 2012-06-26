require 'digest/md5'
module DeadSimpleCMS
  module Storage
    class Base

      # Public: The serializer class used to convert the attributes hash into a String.
      class_attribute :serializer_class

      attr_reader :section

      def initialize(section)
        @section = section
      end

      # Public: Return a hash of the typed attributes from the data source.
      def read
        @_cache ||= (value = read_value) ? serializer_class.load(read_value) : {}
      end

      # Public: Write all the attributes of the section to it's data source. Returns the attributes_hash.
      def write
        hash = attributes_hash
        write_value(serializer_class.dump(hash))
        @_cache = hash # set @_cache after the write
      end

      # Public: Unique key for use in the storage mechanism.
      def unique_key
        @unique_key ||= section.identifier
      end

      # Creates a unique string to identify this data.
      def to_param
        (value = read_value) ? Digest::MD5.hexdigest(value) : nil
      end

      private

      # Public: Values to store.
      def attributes_hash
        attributes_hash = section.attributes.to_hash
        attributes_hash.each { |k, attr| attributes_hash[k] = attr.value }
      end

      def read_value
        raise(NotImplementedError, "Please provide a read_value method for #{self.class}")
      end

      def write_value(value)
        raise(NotImplementedError, "Please provide a write_value method for #{self.class}")
      end

    end
  end
end
