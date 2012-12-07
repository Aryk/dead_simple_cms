module DeadSimpleCMS
  class Configuration
    class_attribute :attribute_classes
    self.attribute_classes = []

    def section(identifier, options={}, &block)
      section = DeadSimpleCMS::Section.new(identifier, options, &block)
      DeadSimpleCMS.sections.add(section)
      # Convenience method, allows one to access DeadSimpleCMS.sections.<section_name>
      DeadSimpleCMS.sections.instance_eval %{def #{section.identifier} ; self[#{section.identifier.inspect}] ; end}
    end

    def group_configuration(identifier, options={}, &block)
      DeadSimpleCMS.group_configurations.add(Group::Configuration.new(identifier, options, &block))
    end

    def register_attribute_classes(*classes)
      classes.each do |klass|
        DeadSimpleCMS::Section::Builder.define_attribute_builder_method(klass)
        Group::Configuration.define_attribute_builder_method(klass)
        attribute_classes << klass
      end
    end

    def storage_class(klass=nil, options={})
      if klass
        klass = "DeadSimpleCMS::Storage::#{klass.to_s.classify}".constantize if klass.is_a?(Symbol)
        options.each { |k, v| klass.send("#{k}=", v) }
        Section.storage_class = klass
      end
      Section.storage_class
    end

    def storage_serializer_class(klass=nil)
      Storage::Base.serializer_class = klass if klass
      Storage::Base.serializer_class
    end

    def default_form_builder(klass=nil)
      if klass
        klass = "DeadSimpleCMS::Rails::ActionView::FormBuilders::#{klass.to_s.classify}".constantize if klass.is_a?(Symbol)
        DeadSimpleCMS::Rails::ActionView::Presenter.form_builder = klass
      end
      DeadSimpleCMS::Rails::ActionView::Presenter.form_builder
    end

    def file_uploader_class(klass=nil)
      Attribute::Type::File.uploader_class = klass if klass
      Attribute::Type::File.uploader_class
    end

  end
end
