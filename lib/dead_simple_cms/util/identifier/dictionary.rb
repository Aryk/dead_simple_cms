module DeadSimpleCMS
  module Util
    module Identifier
      # Public: a dictionary of objects along with their identifiers. Since we are indexing by the identifier, we extend
      # from Hash since that is our primary data store for the objects. We also enforce the condition that the values must
      # be of a +target_class+.
      class Dictionary < Hash
        class DuplciateItem < StandardError ; end
        class InvalidEntryClass < StandardError ; end

        attr_reader :target_class, :identifier_method

        def initialize(target_class, *args, &block)
          options = args.extract_options!
          @identifier_method = options[:identifier_method] || :identifier
          @target_class = target_class
          super(*args, &block)
        end

        def identifiers
          keys
        end

        # Public: Convenience method for adding item by it's identifier.
        def add(item)
          self[to_identifier(item)] = item
        end

        def include?(key)
          key?(to_identifier(key))
        end

        def to_hash
          Hash[self]
        end

        # Public: set a record for the dictionary.
        #
        #  * If the value is not of type target_class, raise an error.
        #  * If the record already exists, raise an error.
        def []=(key, value)
          raise InvalidEntryClass, "Only entries with class #{target_class} can be added" unless value.is_a?(target_class)
          identifier = to_identifier(key)
          raise DuplciateItem, "#{identifier} already present in dictionary." if key?(identifier)
          super(identifier, value)
        end

        def [](key)
          result = super(to_identifier(key))
          maybe_build_block(result)
          result
        end

        def each(&block)
          super do |k, v|
            maybe_build_block(v)
            block[k, v]
          end
        end

        def values
          results = super
          results.each do |result|
            maybe_build_block(result)
          end
          results
        end

        private

        def maybe_build_block(value)
          value.build_block! if value.respond_to?(:build_block!)
        end

        # Private: Cast an identifier or other object into an identifier.
        def to_identifier(identifier)
          case identifier
          when String, Symbol   then identifier.to_sym
          when Util::Identifier then identifier.send(identifier_method) # if module is included
          end
        end

      end
    end
  end
end
