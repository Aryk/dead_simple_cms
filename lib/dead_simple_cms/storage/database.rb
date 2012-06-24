module DeadSimpleCMS
  module Storage
    class Database < Base

      # Public: Table used to store the key/value pairs for the CMS
      #
      #   Structure
      #      * key: varchar
      #      * value: text
      #
      class Table < ActiveRecord::Base
        self.table_name = "dead_simple_cms"
        validates :key, :presence => true, :uniqueness => true
      end

      class_attribute :active_record
      self.active_record = Table

      private

      def read_value
        record = active_record.find_by_key(unique_key)
        record && record.value
      end

      def write_value(value)
        record = active_record.find_or_create_by_key(unique_key)
        record.update_attribute(:value, value)
      end

    end
  end
end