require 'delegate'
module DeadSimpleCMS
  module Rails
    module ActionView
      class Presenter < SimpleDelegator

        class_attribute :form_builder

        def initialize(template)
          __setobj__(template)
        end

        # Renders a group into the view.
        def group(group, *args, &block)
          group.render(__getobj__, *args, &block) # pass through the action_view template.
        end

        def sections
          DeadSimpleCMS.sections.values.map { |section| section(section, options) }.join.html_safe
        end

        # Public: Render the dead simple cms with tabs
        # This is *coupled* with twitter bootstrap. If you are running it, this will work great, otherwise this will be sad.
        # http://twitter.github.com/bootstrap/javascript.html#tabs
        def with_bootstrap_tabs(options={})
          js = javascript_include_tag(options.delete(:bootstrap_tab_js) || "bootstrap-2.0.3/bootstrap-tab.js")
          js << javascript_tag(<<-JAVASCRIPT)
          $(document).ready(function() {
            var $tabs = $('#section-tabs a') ;
            $tabs.click(function (e) { e.preventDefault(); $(this).tab('show'); });
            $("#" + (window.location.hash.replace("#", "") || "#{DeadSimpleCMS.sections.identifiers[0]}") + "-tab").tab('show');
          })
          JAVASCRIPT
          lis = DeadSimpleCMS.sections.values.map do |section|
            content_tag(:li, link_to(section.label, "##{section.identifier.to_s.csserize}", :id => "#{section.identifier.to_s.csserize}-tab"))
          end.join.html_safe
          tabs = content_tag(:ul, lis, :class => "nav nav-tabs", :id => "section-tabs")
          sections = content_tag(:div, :class => "tab-content") do
            DeadSimpleCMS.sections.values.map do |section|
              content_tag(:div, section(section), :class => "tab-pane", :id => "#{section.identifier.to_s.csserize}")
            end.join.html_safe
          end
          js + tabs + sections
        end

        def section(section, options={})
          content_tag(:h2, section.label) + form(section, options)
        end

        def form(section, options={})
          options.reverse_merge!(:builder => form_builder, :url => {:action => :edit})
          options.reverse_merge!(options[:builder].form_for_options)

          (options[:html] ||= {}).update(:multipart => true) if section.attributes.values.any? { |a| a.input_type == :file }

          send(options[:builder].form_for_method, section, {:as => section.identifier}.update(options)) do |form|
            form.fields_for_group(section, options) + form.actions { form.update + form.preview(section) }
          end
        end
      end
    end
  end
end
