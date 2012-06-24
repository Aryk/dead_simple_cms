module DeadSimpleCMS
  module Attribute
    class Collection
      include Util::Identifier

      attr_reader :attributes

      delegate :[], :[]=, :to => :attributes

      # The method used to construct the identifier (key) by which the attribute (value) will be stored with.
      class_attribute :dictionary_identifier_method
      self.dictionary_identifier_method = :identifier

      def initialize(identifier, options={})
        @attributes = Attribute::Type::Base.new_dictionary(:identifier_method => dictionary_identifier_method)
        super
      end

      # Play nicely with Rails fields_for.
      def persisted?
        false
      end

      def update_attributes(attributes)
        attributes.each { |k, v| send("#{k}=", v) }
      end

      def add_attribute(attribute)
        attributes.add(attribute)
        attribute_accessor(attribute)
      end

      private

      def attribute_accessor(attribute)
        identifier = attribute.send(dictionary_identifier_method)
        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{identifier}     ; attributes[#{identifier.inspect}].value     ; end
          def #{identifier}=(v) ; attributes[#{identifier.inspect}].value = v ; end
        RUBY
      end

    end
  end
end