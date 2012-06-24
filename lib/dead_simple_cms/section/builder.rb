module DeadSimpleCMS
  class Section
    # Public: A Builder class which provides a nice DSL to describe different sections of the site that a user wants to modify
    # through a CMS.
    class Builder

      attr_accessor :group_hierarchy
      attr_reader :section

      def self.define_attribute_builder_method(klass)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{klass.builder_method_name}(identifier, options={})
            group_hierarchy = self.group_hierarchy.presence || [section.root_group] # fallback on the root group
            attribute = #{klass}.new(identifier, options.merge(:group_hierarchy => group_hierarchy, :section => section))
            group_hierarchy.last.add_attribute(attribute)
            section.add_attribute(attribute)
          end
        RUBY
      end

      def initialize(section, &block)
        @section = section
        @group_hierarchy = []
        instance_eval(&block)
      end

      def display(*args, &block)
        (current_group || section).display(*args, &block)
      end

      def group(*args, &block)
        options = args.extract_options!
        attribute_options_by_identifier = options.delete(:attribute_options) || {}

        identifier = args.first
        # If no identifier provided, first key, value pair of the hash is the identifier => group_configuration.
        identifier, group_configuration = options.shift unless identifier
        unless group_configuration.is_a?(DeadSimpleCMS::Group::Configuration)
          group_configuration = DeadSimpleCMS.group_configurations[group_configuration]
        end
        options.update(group_configuration.options) if group_configuration
        group = Group.new(identifier, options)

        nest_group(group) do
          if group_configuration
            display(group_configuration.presenter_class, &group_configuration.render_proc)
            group_configuration.attribute_arguments.each do |attribute_identifier, (attribute_type, attribute_options)|
              attribute_options = attribute_options.merge(attribute_options_by_identifier[attribute_identifier] || {})
              send(attribute_type, attribute_identifier, attribute_options)
            end
          end
          instance_eval(&block) if block_given?
        end
      end

      private

      def current_group
        group_hierarchy.last
      end

      def nest_group(group)
        tmp = group_hierarchy
        (group_hierarchy.last || section).add_group(group) # chain it with the last group or section if its top-level.
        self.group_hierarchy += [group]
        yield
      ensure
        self.group_hierarchy = tmp
      end

    end # Builder
  end
end