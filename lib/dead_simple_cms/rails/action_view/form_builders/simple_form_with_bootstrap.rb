module DeadSimpleCMS
  module Rails
    module ActionView
      module FormBuilders
        class SimpleFormWithBootstrap < SimpleForm

          self.form_for_options = {:wrapper => :bootstrap, :html => { class: "form-horizontal well dead-simple-cms" }}
          self.update_options   = {:class => "btn-primary"}
          self.actions_options  = {:class => "form-actions btn-group"}
          self.preview_options  = {:class => "btn"}

        end
      end
    end
  end
end



