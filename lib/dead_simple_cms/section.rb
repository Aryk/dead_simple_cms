module DeadSimpleCMS
  # Public: Represents a section in the website a user wants to be able to modify the data in an immediate-simple way.
  class Section < Group

    include ActiveModel::Observing

    extend ActiveModel::Callbacks
    define_model_callbacks :save

    self.dictionary_identifier_method = :section_identifier

    # Public: a Symbol representing the default storage class
    class_attribute :storage_class, :instance_writer => false

    attr_reader :path, :root_group

    before_save :upload_file_attributes

    delegate :to_param, :to => :storage

    def initialize(identifier, options={}, &block)
      super(identifier, options)
      @path       = options[:path]
      @root_group = Group.root # The root group for the section.
      @fragments  = Array.wrap(options[:fragments])
      add_group(@root_group)

      build(&block) if block_given?
    end

    # Public: Update the sections with the params and return the updated sections.
    def self.update_from_params(params)
      params.map do |section_identifier, attributes|
        DeadSimpleCMS.sections[section_identifier].tap do |section|
          section.update_attributes(attributes) if section
        end
      end.compact
    end

    def add_attribute(attribute)
      super
      attribute.section = self
    end

    def fragments
      @fragments.map { |f| f.is_a?(Proc) ? f.call(self) : f }.flatten.uniq
    end

    def storage
      @storage ||= storage_class.new(self)
    end

    # Public: Clears out the storage so new values can be repopulated. Used primarily to clear the values between refreshes.
    def refresh!
      @storage = nil
    end

    # Public: Update the section values.
    #
    # Examples
    #
    #   update_attributes("left_attributes" => {"header" => "Hi There", "paragraph" => "how's it going"}})
    #   update_attributes("left_header" => "Hi There", "left_paragraph" => "how's it going"})
    #
    # Both of these work assuming the user defined a group called "left" and has attributes in it called "header" and
    # "paragraph". The "left_attributes=" method plays nicely with nested fields_for which the form builder dependes on.
    def update_attributes(attributes)
      super
      save!
    end

    def save!
      _run_save_callbacks { storage.write }
    end

    def build(&block)
      Builder.new(self, &block)
    end

    def cache_key
      "cms/#{identifier}"
    end

    private

    # Tried to make an observer class for the uploading, but had some trouble getting it working. - Aryk
    def upload_file_attributes
      attributes.values.each { |a| a.upload! if a.is_a?(Attribute::Type::File) }
    end

    def attribute_accessor(attribute)
      super
      identifier = attribute.send(dictionary_identifier_method)
      # If the attribute is in the root group, then create an alias from "root_foo" to simply "foo"
      if attribute.root_group?
        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          alias #{attribute.identifier} #{identifier}
          alias #{attribute.identifier}= #{identifier}=
        RUBY
      end
    end

  end
end
