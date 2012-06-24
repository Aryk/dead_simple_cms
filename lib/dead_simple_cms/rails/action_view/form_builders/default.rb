module DeadSimpleCMS
  module Rails
    module ActionView
      module FormBuilders
        # Public: Interface for buildering form builders to work with this library.
        class Default < ::ActionView::Helpers::FormBuilder

          include Interface

          self.actions_options  = {:class => "form-actions"}

        end
      end
    end
  end
end