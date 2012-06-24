module DeadSimpleCMS
  module Rails
    module ActionView
      # Public: Class to handle expiring the fragment caches from the cms.
      # ::ActionController::Caching::Sweeper inherits from ActiveRecord::Observer even though we aren't observing an
      # ActiveRecord class. This still works though because the interface (update callback) is the same on the Section.
      class FragmentSweeper < ::ActionController::Caching::Sweeper

        observe DeadSimpleCMS::Section

        # Make sure we expire any fragments that we are using on those pages.
        def after_save(section)
          section.fragments.each { |f| expire_fragment(f) }
        end

      end
    end
  end
end