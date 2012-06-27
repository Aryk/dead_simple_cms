module DeadSimpleCMS
  module Rails
    class Railtie < ::Rails::Railtie

      initializer "dead_simple_cms.section_refresher" do |app|
        require 'dead_simple_cms/rack/section_refresher'
        app.config.middleware.use(DeadSimpleCMS::Rack::SectionRefresher)
      end

    end
  end
end