require File.expand_path('../setup/test_file_uploader', __FILE__)
require File.expand_path('../setup/banner_presenter', __FILE__)
require File.expand_path('../setup/shared', __FILE__)


DeadSimpleCMS.configure do

  default_form_builder :default

  file_uploader_class DeadSimpleCMS::TestFileUploader
  
  storage_class :database

  group_configuration(:image_tag) do
    image :url, :required => true
    string :alt, :default => "Design Beautiful Books"
    string :href, :hint => "Here is the hint.", :required => true

    display do |group, html_options, image_html_options|
      (image_html_options ||= {}).reverse_merge!(:alt => group.alt)
      image_html_options[:alt] = image_alt_for_seo(image_html_options[:alt]) if image_html_options[:alt]
      link_to_if(group.href, image_tag(group.url, image_html_options), group.href, html_options)
    end
  end

end
