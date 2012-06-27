require 'rack'
module DeadSimpleCMS
  module Rack
    # Public: Refresh the DeadSimpleCMS values in between requests. Since DeadSimpleCMS stores all the attributes for a
    # section in a serialized format, we cache the storage mechanism on a per-request basis to avoid unnecessary hits
    # to the cache, whether it be Redis, Memcache, or the Database.
    class SectionRefresher

      def initialize(app, options = {})
        @app = app
      end

      def call(env)
        DeadSimpleCMS.sections.values.each(&:refresh!)
        @app.call(env)
      end

    end
  end
end
