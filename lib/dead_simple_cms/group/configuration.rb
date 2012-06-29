module DeadSimpleCMS
  class Group
    class Configuration

      include Util::Identifier

      require 'dead_simple_cms/group/presenter/render_mixin'
      include Presenter::RenderMixin

      attr_reader :options, :attribute_arguments

      def initialize(identifier, options={}, &block)
        super(identifier, options)
        @options = options
        @attribute_arguments = {}
        instance_eval(&block)
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