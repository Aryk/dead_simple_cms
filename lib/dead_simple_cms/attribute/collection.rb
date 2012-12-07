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
        # Sometimes we have to do initial preparing of attributes, before sending them to updating.
        # For example, if we use select_datetime from Rails, it creates many fields in params, so the resulting
        # params may look like:
        #
        #    {'foo' => 'bar', 'date(1i)' => '2000', 'date(2i)' => '10', 'date(3i)' => '30'}
        #
        # Of course we have to modify it to put everything into the same key, like:
        #
        #    {'foo' => 'bar', 'date' => '2000-10-30'}
        #
        # or something like that. So, if your attribute type requires such transformations, please specify
        # .convert_attributes method in it.
        Configuration.attribute_classes.each do |klass|
          klass.convert_attributes(attributes) if klass.respond_to?(:convert_attributes)
        end
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
