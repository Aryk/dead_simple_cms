module DeadSimpleCMS
  module Rails
    module ActionView
      module FormBuilders
        # Public: SimpleForm builder for use with the Dead Simple CMS
        # The class names embed into this builder are for twitter bootstrap.
        class SimpleForm < ::SimpleForm::FormBuilder

          include Interface

          # Public: Translation of the Attribute::Type::Base#input_type to :as option for SimpleForm.
          AS_LOOKUP = Hash.new { |h, k| k }.update(:radio => :radio_buttons, :check_box => :boolean)

          self.preview_options = {:target => "_blank"}

          def self.form_for_method
            :simple_form_for
          end

          def attribute(attribute)
            as = AS_LOOKUP[attribute.input_type]
            hint = attribute.hint.to_s.dup
            hint << %{ <a href="#{attribute.value}" target="_blank">preview</a>} if attribute.is_a?(Attribute::Type::Image)
            options = {:required => attribute.required, :hint => hint, :as => as, :label => attribute.label}
            if attribute.length
              options[:input_html] = {maxlength: attribute.length}
            end
            if attribute.is_a?(Attribute::Type::CollectionSupport) && (collection = attribute.collection)
              options[:collection] = collection
              options[:include_blank] = false if as==:select
            end

            input(attribute.identifier, attribute_options.merge(options))
          end

          def update
            button(:submit, "Update", update_options)
          end

        end
      end
    end
  end
end

