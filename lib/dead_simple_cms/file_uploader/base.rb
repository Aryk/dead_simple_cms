module DeadSimpleCMS
  module FileUploader
    # Base file uploader class. Inherit from this to build your own uploaders for files.
    class Base

      attr_reader :file_attribute
      delegate :file_ext, :data, :to => :file_attribute

      def initialize(file_attribute)
        @file_attribute = file_attribute
      end

      def upload!
        raise NotImplementedError, "Please overwrite this with your own upload functionality."
      end

      def url
        raise NotImplementedError, "Please overwrite this with your own url constructor."
      end

      # Public: We need to have all these nesting to protect against corner-case collisons.
      def path(namespace="dead_simple_cms")
        # dead_simple_cms/<section>/<group>/attribute.jpg
        @path ||= [namespace, *[file_attribute.section, *file_attribute.group_hierarchy, file_attribute].map(&:identifier)].compact * "/" + "." + file_ext
      end

    end
  end
end