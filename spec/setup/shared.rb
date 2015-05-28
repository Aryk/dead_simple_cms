shared_context :sample_section do

  let(:section) do
    # Site announcement is an example of a potential use case. It leverages a lot of the functionality of the
    # library, hence why we are teting against it.
    section = DeadSimpleCMS::Section.new(:site_announcement, :path => "/") do
      boolean :show_default, :default => false
      string :coupon_code
      group(:top_bar) do
        string :css_class, :collection => %w{facebook default christmas green}, :default => "facebook"
        string :strong, :default => "FREE Priority Shipping on Orders $50+"
        string :normal
        string :action
        string :href
      end
      group(:banners) do
        [[:small, 715, 85], [:large, 890, 123]].each do |size, width, height|
          group size => :image_tag, :attribute_options => {:url => {:width => width, :height => height}} do
            boolean :show
            string :promotional_href, :hint => "Used for all custom coupon banners not from the site announcement."
            display DeadSimpleCMS::BannerPresenter
          end
        end
      end

      extend do
        def test_function

        end
      end
    end
    section.build_block!
    section
  end

end
shared_context :sample_storage do
  include_context :sample_section

  let(:attributes_hash) { subject.send(:attributes_hash) }
  let(:attributes_hash_dump) { Psych.dump(attributes_hash) }

  subject { described_class.new(section).tap { |x| x.serializer_class = Psych } }
end

shared_examples :group_display do

  describe "#display" do
    context "when presenter_class is set" do
      it "should set the @presenter_class variable" do
        klass = Class.new(DeadSimpleCMS::Group::Presenter::Base)
        subject.display klass
        subject.presenter_class.should == klass
      end
    end

    context "when block provided" do
      it "should set it to the @render_proc" do
        proc = lambda { "do something" }
        subject.display(&proc)
        subject.render_proc.should == proc
      end
    end
  end

end
