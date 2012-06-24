module DeadSimpleCMS
  module Rails
    module ActionView
      module FormBuilders
        # Public: Interface used for a form builder to work with dead simple cms.
        module Interface

          def self.included(base)
            base.class_eval do
              class_attribute :form_for_method
              self.form_for_method = :form_for

              class_inheritable_hash :form_for_options
              self.form_for_options = {}

              [:update, :actions, :preview, :attribute].each do |name|
                option_name = "#{name}_options"
                class_inheritable_hash option_name, :instance_writer => false
                self.send("#{option_name}=", {})
              end
            end
            super
          end

          def attribute(attribute)
            label(attribute.identifier, attribute.label) +
              case attribute.input_type
              when :string then text_field(attribute.identifier)
              when :text   then text_area(attribute.identifier)
              when :file   then file_field(attribute.identifier)
              when :select then select(attribute.identifier, attribute.collection)
              when :radio  then radio_buttons(attribute.identifier, attribute.collection)
              else              raise("Unknown type: #{attribute.identifier}")
              end
          end

          def actions(&block)
            @template.content_tag(:div, actions_options, &block)
          end

          def update
            submit("Update", update_options)
          end

          def radio_buttons(identifier, collection)
            collection.map { |v| radio_button(identifier, v) }.join.html_safe
          end

          def preview(section)
            @template.link_to("Preview", section.path, preview_options) if section.path
          end

          def fields_for_group(section_or_group, options={})
            section_or_group.groups.values.map do |group|
              next if group.attributes.empty? && group.groups.empty?
              fields_for(group.identifier, options) do |builder|
                @template.content_tag(:fieldset) do
                  # Following fieldset/legend convention: https://github.com/twitter/bootstrap/issues/1214
                  legend        = @template.content_tag(:legend, group.label) unless group.root? # don't show the group name if it's the root group.
                  attributes    = group.attributes.values.map { |attribute| builder.attribute(attribute) }.join.html_safe
                  nested_groups = builder.fields_for_group(group, options)
                  [legend, attributes, nested_groups].join.html_safe
                end
              end
            end.join.html_safe
          end

        end
      end
    end
  end
end