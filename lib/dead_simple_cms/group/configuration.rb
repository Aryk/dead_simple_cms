module DeadSimpleCMS
  class Group
    class Configuration

      include Util::Identifier

      attr_reader :options, :attribute_arguments, :presenter_class, :render_proc

      def initialize(identifier, options={}, &block)
        super(identifier, options)
        @options = options
        @attribute_arguments = {}
        instance_eval(&block)
      end

      def display(presenter_class=nil, &block)
        @presenter_class = presenter_class if presenter_class
        @render_proc = block if block_given?
      end

      def self.define_attribute_builder_method(klass)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{klass.builder_method_name}(identifier, options={})
            attribute_arguments[identifier] = [#{klass.builder_method_name.inspect}, options]
          end
        RUBY
      end

    end

  end
end