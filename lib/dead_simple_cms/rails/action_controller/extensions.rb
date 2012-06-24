module DeadSimpleCMS
  module Rails
    module ActionController
      module Extensions

        extend ActiveSupport::Concern

        module ClassMethods
          def cms_cache_sweeper(options={})
            cache_sweeper ActionView::FragmentSweeper, options
          end
        end

        private

        # Private: Update the values for the cms with the arguments from the params hash.
        def update_sections_from_params
          DeadSimpleCMS::Section.update_from_params(params)
        end

      end
    end
  end
end
