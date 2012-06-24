module DeadSimpleCMS
  module Attribute
    module Type
      class String < Base
        self.default_input_type = :string
        include CollectionSupport
      end
      class Text < String
        self.default_input_type = :text
      end
      class Symbol < Base
        self.default_input_type = :string
        def convert_value(value)
          value.to_s.to_sym if value.present?
        end
        private :convert_value
      end
      class Boolean < Base
        self.default_input_type = :radio

        include CollectionSupport

        def initialize(identifier, options={})
          options.update(:collection => [true, false], :default => false)
          super
        end

        private

        def convert_value(value)
          value.is_a?(::String) ? ["true", "1"].include?(value.downcase) : !!value
        end

      end
      class Numeric < Base
        self.default_input_type = :string
        include CollectionSupport
      end
      class Integer < Numeric
        def convert_value(value)
          value && value.to_i
        end
      end
      # Public: File attributes are stored at some publicly accessible url.
      class File < Base
        self.default_input_type = :file

        attr_accessor :data, :file_ext

        class_attribute :uploader_class

        alias :url :value

        def initialize(identifier, options={})
          @data     = options[:data]
          @file_ext = options[:file_ext] || "dat"
          super
        end

        # Public: Takes the current #value, detects if its an object to upload and replaces the #value with the url
        # to be stored in the CMS.
        def upload!
          raise NotImplementedError, "Please define an uploader class (see DeadSimpleCMS::FileUploader::Base)" unless uploader_class
          return unless data

          s3_uploader = uploader_class.new(self)
          s3_uploader.upload!
          self.value = s3_uploader.url
        end

        private

        def convert_value(value)
          case value
          when ::String, NilClass
            value
          when ActionDispatch::Http::UploadedFile
            @file_ext = value.original_filename[/\.(.+)$/, 1]
            value.rewind # make sure it's rewound
            self.data = value.read
            @value # just return the same stored @value so it doesn't change for now
          else
            raise("Don't know how to convert value: #{value.inspect}")
          end
        end

      end
      class Image < File

        attr_reader :width, :height

        def initialize(identifier, options={})
          @width, @height = options.values_at(:width, :height)
          super
        end

        def hint
          super || "Image should be #{width} x #{height}."
        end

      end
    end
  end
end