module DeadSimpleCMS
  module Attribute
    module Type
      class Base

        include Util::Identifier

        class << self
          # Public: the method name used to identify this type in the Builder
          attr_writer :builder_method_name

          # If not provided on the subclass infer it from the class name. Because of how class_attribute works, this
          # method will be overwritten when someone explicitly calls .builder_method_name= on a subclass.
          def builder_method_name
            @builder_method_name ||=  name.demodulize.underscore
          end

        end

        # Public: a Symbol representing the default input type required for forms
        class_attribute :default_input_type, :instance_writer => false

        VALID_INPUT_TYPES = [:string, :text, :select, :file, :radio, :datetime].freeze

        attr_reader   :input_type, :group_hierarchy, :required
        attr_accessor :section

        def initialize(identifier, options={})
          options.reverse_merge!(:group_hierarchy => [], :input_type => default_input_type, :required => false)
          @hint, @default, @input_type, @group_hierarchy, @section, @required =
            options.values_at(:hint, :default, :input_type, :group_hierarchy, :section, :required)
          raise("Invalid input type: #{input_type.inspect}. Should be one of #{VALID_INPUT_TYPES}.") unless VALID_INPUT_TYPES.include?(input_type)
          super
        end

        def root_group?
          group_hierarchy.last.try(:root?)
        end

        # Public: The identifier on the section level. It must be unique amongst the groups.
        def section_identifier
          (group_hierarchy + [self]).map(&:identifier).join("_").to_sym
        end

        def hint
          @hint.is_a?(Proc) ? @hint.call : @hint
        end

        def default
          @default.is_a?(Proc) ? @default.call : @default
        end

        def value=(value)
          attributes_from_storage[section_identifier] = convert_value(value)
        end

        # Public: Returns the non-blank value from the storage or the default.
        def value
          attributes = attributes_from_storage
          attributes.key?(section_identifier) ? attributes[section_identifier] : default
        end

        def inspect
          ivars = [:identifier, :hint, :default, :required, :input_type].map { |m| ivar = "@#{m}" ; "#{ivar}=#{instance_variable_get(ivar).inspect}" }
          "#<#{self.class} #{ivars.join(", ")}"
        end

        private

        def attributes_from_storage
          section.storage.read
        end

        def convert_value(value)
          value.presence
        end

      end
    end
  end
end
