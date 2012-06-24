module DeadSimpleCMS
  module Attribute
    module Type
      module CollectionSupport

        VALID_COLLECTION_INPUT_TYPES = [:select, :radio].freeze

        DEFAULT_COLLECTION_INPUT_TYPE = :select

        def initialize(identifier, options={})
          if @collection = options[:collection]
            # Pick either the options[:input_type], default_input_type, or the :select. Whichever matches the valid types.
            options[:input_type] = ([options[:input_type], default_input_type, DEFAULT_COLLECTION_INPUT_TYPE] & VALID_COLLECTION_INPUT_TYPES).first
          end
          super
        end

        # Public: For performance and loading reasons, we allow the ability to pass through a collection as a lambda.
        def collection
          @collection.is_a?(Proc) ? @collection.call : @collection
        end

      end
    end
  end
end
