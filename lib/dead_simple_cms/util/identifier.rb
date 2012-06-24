require 'dead_simple_cms/util/identifier/dictionary'
module DeadSimpleCMS
  module Util

    # Public: A module for the convention of having an identifier:
    #
    #  * an identifier (Symbol)
    #  * a label (default: titleize) to present to the world
    #  * a collection for looking up items based on their `identifier`
    #
    # We specifically got away from having a "name" as that usually leads to confusion. Is the name the "foo_bar" name or the
    # pretty "Foo Bar" name?
    module Identifier
      extend ActiveSupport::Concern

      included do
        attr_accessor :label, :identifier
      end

      module InstanceMethods

        def initialize(identifier, options={})
          @identifier = identifier.to_sym
          @label = options[:label] || identifier.to_s.titleize
          super()
        end

      end

      module ClassMethods

        # Public: creates a new dictionary class.
        def new_dictionary(*args, &block)
          Dictionary.new(self, *args, &block)
        end

      end
    end
  end
end