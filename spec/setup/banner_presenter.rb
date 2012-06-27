module DeadSimpleCMS
  class BannerPresenter < DeadSimpleCMS::Group::Presenter::Base

    attr_reader :coupon, :options, :size

    def render
      link_to_if(group.href, image_tag(group.url, :alt => group.alt), group.href) if group.show
    end

    private

    def initialize_extra_arguments(coupon, options={})
      @coupon, @options = coupon, options
      @size = options.delete(:size) || :small # Currently we have two sizes for these banners: 715x85 and 890x123. - Aryk
      raise("Invalid size: #{size}") unless [:small, :large].include?(size)
    end

  end
end