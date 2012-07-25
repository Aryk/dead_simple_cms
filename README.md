Dead Simple CMS
======

Dead Simple CMS is a library for modifying different parts of your website without the overhead of having a
fullblown CMS. The idea with this library is simple: provide an easy way to hook into different parts of your
application (not only views) by defining the different parts to modify in an easy, straight-forward DSL.

The basic components of this library include:

 * A DSL to define the changeable values in your app
 * Form generators based on SimpleForm (with or without Bootstrap) and default rails FormBuilder
 * Expandable storage mechanisms so you can store the data in different locations
   * Currently supported: Redis, Database, Memcache, even Memory (for testing)
 * Presenters/renderers so you can take groups of variables and render them into your views (ie image_tag)

What it doesn't have:

 * Versioning - be able to look at old versions of the content
 * Timing - set start and end time for different content
 * Page builder tools - this is not the right tool if you want to design full pages

Install
------------

`gem install dead_simple_cms`

Setup
------------

Before getting started, it's important to note that this Gem does not have generators for building migrations, yet, 
so integrating it with the app is sort of manual process for now.

----

If you're Redis store isn't persistent, you can use the default option of using the database.
If you decide to use the database, you can create the schema with this:

```ruby
  create_table :dead_simple_cms, :force => true do |t|
    t.string :key
    t.text :value
    t.timestamps
  end
  add_index :dead_simple_cms, :key, :unique => true
```

Now, let's add the controller methods. Find (or create) a controller you want to use for your CMS:

```ruby
class Admin::CmsController < Admin::ApplicationController

  include DeadSimpleCMS::Rails::ActionController::Extensions

  cms_cache_sweeper :only => :edit

  def edit
    if request.post?
      sections_updated = update_sections_from_params
      redirect_to :action => :edit
    end
  end

end
```

In your CMSHelper, add the view helper methods:

```ruby
module Admin
  module CmsHelper
    include DeadSimpleCMS::Rails::ActionView::Extensions
  end
end
```

This will give you access to the CMS presenter:

```ruby
def dead_simple_cms
  @dead_simple_cms ||= Presenter.new(self)
end
```

From here you can do:

```ruby
<%= dead_simple_cms.with_bootstrap_tabs %>
```

to render the forms for the different sections along with tabs to switch between them.

Or, if you don't have bootstrap installed, you can use the default form builder and simply call:

```ruby
<%= dead_simple_cms.sections %>
```

Configuration
-------------

Create an initializer for your app in lib/config/initializers/dead_simple_cms. You can overwrite any of the original
settings. Here is an example template from which you can modify on your own.

```ruby
DeadSimpleCMS.configure do

  default_form_builder :simple_form_with_bootstrap

  file_uploader_class Mixbook::DeadSimpleCMS::FileUploader

  link_hint = "Please enter just the path (ie '/some-path')"

  # In the group_configuration you can create configurations to use to bootstrap other groups. See below.
  group_configuration(:image_tag) do
    image :url, :required => true
    string :alt, :default => "Design Beautiful Books"
    string :href, :hint => link_hint, :required => true

    # To render the display, just call #render with the instance of the view.
    #
    #  <%= group.render(self, {:class => "hi there"}, :alt => "alt value") %>
    display do |group, html_options, image_html_options|
      (image_html_options ||= {}).reverse_merge!(:alt => group.alt)
      link_to_if(group.href, image_tag(group.url, image_html_options), group.href, html_options)
    end
  end

  section(:application) do
    group(:settings) do
      [:option1, :option2, :options3].each do |setting|
        boolean setting
      end
    end
  end

  section(:products_page, :path => "/products") do
    [:left, :center, :right].each do |pos|
      group(pos) do
        image :url, :width => 272, :height => 238, :default => "/images/products_lander/products_1.jpg"
        # You can provide a default value as well, for when the CMS starts up.
        string :header, :default => "#{pos.to_s.titleize} Header"
        
        # Define a collection on "string", "integer" or "numeric" types if you want to limit the user to only a couple 
        # of options. You can pass in an array or a lambda which yields an array (for deferred instantiation).
        string :product_scope, :collection => lambda { SomeTable.all.map(&:product_scope) },
          :default => "books"
          
        string :href, :hint => link_hint

        # In case you need to include customer helpers to a group. You can also extend the top-level section as well.
        extend(SomeModule) do
          def even_more_methods
            href + "?books=true" if product_scope=="books"
          end
        end
      end
    end
  end

  # Here we create another CMS section for the cards page. I can define the :fragments to sweep in either a Hash
  # or a lambda with the section yielded.
  section(:cards_page, :path => "/cards",
    :fragments => lambda { |section| {:controller => "/some_controller", :action => :index, :product_type => "cards", :section => section} }) do

    # Here, we leverage the :image_tag group_configuration from above. Any values that are already present will be 
    # overwritten by the values below.
    group(:hero => :image_tag, :attribute_options => {
      :url => {:width => 715, :height => 301, :default => "/images/storefront/design_beautiful_wedding_invitations.jpg"},
      :alt   => {:default => "Design Beautiful Books"},
      :href  => {:hint => link_hint, :default => "cards/wedding-invitations"}
    })
  end

  section(:site_announcement, :path => "/") do
    boolean :show_default, :default => false
    [:current, :default].each do |type|
      group(type) do
        string :coupon_code
        group(:top_bar) do
          string :css_class, :collection => %w{facebook default christmas green}, :default => "facebook"
          string :strong, :default => "FREE Priority Shipping on Orders $50+"
          string :normal
          string :action
          string :href
          
          # Here we can display custom presenter for this content. The presenter class must respond_to "render"
          # with the current template as the first arg, and any other arguments afterwards.
          display Mixbook::DeadSimpleCMS::Presenters::SiteAnnouncement::TopBarPresenter
        end
        group :banner => :image_tag, :width => 400, :height => 600 do
          # Here additional fields to add onto the group.
          boolean :show
          string :promotional_href, :hint => "Used for all custom coupon banners not from the site announcement."
          display Mixbook::DeadSimpleCMS::Presenters::SiteAnnouncement::BannerPresenter
        end
      end
    end
  end

end
```

For the view presenters, inherit from the `::DeadSimpleCMS::Group::Presenter`. 

```ruby
# Public: Handles the banners on the site.
class BannerPresenter < ::DeadSimpleCMS::Group::Presenter

  attr_reader :coupon, :options, :size

  # The render method is used to create the html that will be inserted into the page.
  def render
    return unless coupon
    url, alt, href, show, html_options = if coupon.same_code?(site_announcement.coupon_code)
      [group.url, group.alt, group.href, group.show, {}]
    else
      url = "http://www.gettyimages.com/basketball.jpg"
      [url, nil, group.promotional_href, true, {:onerror => "$(this).hide()"}]
    end

    # We can use any method accessible from the template since we simply delegate to the template.
    link_to_if(href, image_tag(url, html_options.update(:class => "banner", :alt => alt)), href) if show
  end

  private

  # If you define this method, you can add on additional arguments. I created a separate function like this instead of
  # overwriting initialize since I don't want the user to have to know how this works internally.
  def initialize_extra_arguments(coupon, options={})
    @coupon, @options = coupon, options
    @size = options.delete(:size) || :small # Currently we have two sizes for these banners: 715x85 and 890x123. - Aryk
    raise("Invalid size: #{size}") unless [:small, :large].include?(size)
  end

end
```

Then in your views, you can do:

```ruby
<%= DeadSimpleCMS.sections.current.banner.render(self, coupon, :size => :large) %>
```

For the file uploader, simply extend from ::DeadSimpleCMS::FileUploader::Base and add #url and #upload! methods.

```ruby
class Mixbook::DeadSimpleCMS::FileUploader < ::DeadSimpleCMS::FileUploader::Base

  def url
    # this should retrieve the url to where the photo will be uploaded to.
  end

  def upload!
     AWS::S3::S3Object.store(path, data, "mybucket", :access => :public_read)
  end

end
```

Accessing Values
-----

To access the values and modify them directly:

```ruby
DeadSimpleCMS.sections.section1.group1.group2.group3.attribute = "new value"
DeadSimpleCMS.sections.section1.save!

# Access the data:
DeadSimpleCMS.sections.section1.group1.group2.group3.attribute # => "new value"
DeadSimpleCMS.sections.section1.groups[:group1].groups[:group2].attributes[:attribute].value # => "new value"
```

Meta
----

Dead Simple CMS was originally written by Aryk Grosz in the course of a week for [mixbook.com](http://www.mixbook.com).

Mixbook is based in Palo Alto (near California Ave) and we're hiring. We like dogs, beer, and music. If you're 
passionate (read: anal) about creating high quality products and software that makes people happy, please reach out 
to us at jobs@mixbook.com.

Author
------

Aryk Grosz :: aryk.grosz@gmail.com :: @arykg