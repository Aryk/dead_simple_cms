require 'delegate'
module DeadSimpleCMS
  class Group
    module Presenter
      # Public: Module to add rendering of lambda and presenters for DeadSimpleCMS::Group.
      module RenderMixin

        def presenter_class
          display if display.is_a?(Class) && display < Presenter::Base
        end

        def render_proc
          display if display.is_a?(Proc)
        end

        # Public: Set different mechanisms for rendering this group.
        def display(presenter_class_or_block=nil, &block)
          @display = presenter_class_or_block if presenter_class_or_block
          @display = block if block_given?
          @display
        end

        # Public: Render the group using the passed in proc in the scope of the template.
        #
        # If you include this module in something other then a DeadSimpleCMS::Group, you can pass in the +group+ directly with
        # the first argument:
        #
        #   render([view_context, group], *args) # and also
        #   render(view_context, *args)
        #
        def render(view_context, *args)
          view_context, group = view_context.is_a?(Array) ? view_context : [view_context, self]
          case display
          when Proc  then view_context.instance_exec(group, *args, &display)
          when Class then display.new(view_context, group, *args).render if display < Presenter::Base
          end
        end

      end
    end
  end
end