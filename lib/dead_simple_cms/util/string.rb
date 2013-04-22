module DeadSimpleCMS
  module Util
    module String
      class << self
        # Converts string into css DOM selector for use with class and ID. We
        # currently do lowercase with dashes for cssnames.
        def csserize(str)
          name = str.to_s.dup
          name.gsub!(/[^A-Za-z0-9]+/, " ") # can return nil
          name.gsub!(/(\w)([A-Z])/, '\1-\2') # can return nil
          name.squish!.downcase!
          name.gsub!(" ", "-") # can return nil
          name
        end
      end
    end
  end
end