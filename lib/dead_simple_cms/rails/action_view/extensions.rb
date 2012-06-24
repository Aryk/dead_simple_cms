module DeadSimpleCMS
  module Rails
    module ActionView
      module Extensions

        def dead_simple_cms
          @dead_simple_cms ||= Presenter.new(self)
        end

      end
    end
  end
end

