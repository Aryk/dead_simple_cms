require 'rubygems'
require "dead_simple_cms/version"

module DeadSimpleCMS ; end

# These are the only two things needed from the rails family to run this. ActiveModel is necessary for observing and
# callbacks done in the DeadSimpleCMS::Section class.
require 'active_support/core_ext'
require 'active_model'

require 'dead_simple_cms/configuration'

require 'dead_simple_cms/util/identifier'
require 'dead_simple_cms/file_uploader/base'

require 'dead_simple_cms/storage/base'
require 'dead_simple_cms/storage/memory'
module DeadSimpleCMS::Storage
  autoload :RailsCache, 'dead_simple_cms/storage/rails_cache'
  autoload :Redis,      'dead_simple_cms/storage/redis'
  autoload :Database,   'dead_simple_cms/storage/database'
end

require 'dead_simple_cms/attribute/collection'

require 'dead_simple_cms/attribute/type/collection_support'
require 'dead_simple_cms/attribute/type/base'
require 'dead_simple_cms/attribute/type/all'

require 'dead_simple_cms/group'
require 'dead_simple_cms/group/configuration'
require 'dead_simple_cms/group/presenter/base'
require 'dead_simple_cms/group/presenter/render_mixin'

require 'dead_simple_cms/section'
require 'dead_simple_cms/section/builder'

if defined?(ActionView)
  require 'dead_simple_cms/rails/action_view/form_builders/interface'
  require 'dead_simple_cms/rails/action_view/form_builders/default'
  module DeadSimpleCMS::Rails::ActionView::FormBuilders
    autoload :SimpleForm,              'dead_simple_cms/rails/action_view/form_builders/simple_form'
    autoload :SimpleFormWithBootstrap, 'dead_simple_cms/rails/action_view/form_builders/simple_form_with_bootstrap'
  end

  require 'dead_simple_cms/rails/action_view/extensions'
  require 'dead_simple_cms/rails/action_view/presenter'
end

if defined?(ActionController)
  require 'dead_simple_cms/rails/action_controller/extensions'
  require 'dead_simple_cms/rails/action_controller/fragment_sweeper'
end

if defined?(Rails)
  require 'dead_simple_cms/rails/railtie'
end

module DeadSimpleCMS

  extend self

  def configuration
    @configuration ||= Configuration.new
  end

  def configure(&block)
    configuration.instance_eval(&block)
  end

  def sections
    @sections ||= Section.new_dictionary
  end

  def group_configurations
    @group_configurations ||= Group::Configuration.new_dictionary
  end

  configure do

    # Register any additional attribute classes for use in your configuration.
    register_attribute_classes(Attribute::Type::String, Attribute::Type::Text, Attribute::Type::Numeric, Attribute::Type::Integer,
      Attribute::Type::Float, Attribute::Type::Boolean, Attribute::Type::File, Attribute::Type::Image, Attribute::Type::Symbol,
      Attribute::Type::Datetime)

    # Set the default form builder used for building the CMS forms in the app. You can replace this with :simple_form,
    # :simple_form_with_bootstrap or pass in the actual builder class. Your builder class must include the interface:
    # DeadSimpleCMS::Rails::ActionView::FormBuilders::Interface.
    default_form_builder :default if defined?(ActionView)

    # Set the default storage class for attributes to be store. The current available options are
    # [:rails_cache, :database, :redis, :memory]. You can also extend DeadSimpleCMS::Storage::Base and provide your own.
    # If you create your own, please provide the full class name.
    #
    # If you choose to use the database, make sure to create a database table to hold the data:
    #      
    #    create_table :dead_simple_cms, :force => true do |t|
    #      t.string :key
    #      t.text :value
    #      t.timestamps
    #    end
    #    add_index :dead_simple_cms, :key, :unique => true
    #
    if defined?(ActiveRecord)
      storage_class :database
    else
      puts "ATTENTION: DeadSimpleCMS did not find ActiveRecord. It will store the CMS in memory and you will lose it when your application shutsdown!!!"
      storage_class :memory
    end

    # If you are going to use the 'file' type, make sure to provide an uploader class. By default file uploads
    # **WILL NOT WORK**. Create your own uploader by extending from DeadSimpleCMS::FileUploader::Base and creating
    # a #url and a #upload! method.
    #
    # Example
    #
    #   class MyFileUploader < DeadSimpleCMS::FileUploader::Base
    #
    #     def url
    #       # This should retrieve the url to where the photo will be uploaded to.
    #     end
    #       
    #     def upload!
    #       AWS::S3::S3Object.store(path, data, "mybucket", :access => :public_read)
    #     end
    
    #   end
    #
    #
    # file_uploader_class MyOwnFileUploader

    # Set the serializer class to use. It must output to a string and have #dump and #load methods on it.
    require 'psych'
    storage_serializer_class Psych

  end

end
