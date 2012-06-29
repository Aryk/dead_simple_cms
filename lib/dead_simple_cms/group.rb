module DeadSimpleCMS
  # Public: A Group is essentially an Attribute::Collection with the ability to have it's own groups on it with infinite
  # nesting of groups.
  class Group < Attribute::Collection

    ROOT_IDENTIFIER = :root

    attr_reader :groups
    attr_accessor :parent

    require 'dead_simple_cms/group/presenter/render_mixin'
    include Presenter::RenderMixin

    def initialize(identifier, options={})
      @groups = DeadSimpleCMS::Group.new_dictionary
      super
    end

    def self.root
      new(ROOT_IDENTIFIER)
    end

    # Public: Exend functionality for the current group.
    def extend(*modules, &block)
      modules << Module.new(&block) if block_given?
      super(*modules)
    end

    def root?
      identifier == ROOT_IDENTIFIER
    end

    def add_group(group)
      group.parent = self
      groups.add(group)
      group_accessor(group)
    end

    private

    # The <group>_attributes method plays nice with form builder's fields_for.
    def group_accessor(group)
      instance_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{group.identifier}_attributes=(v) ; groups[#{group.identifier.inspect}].update_attributes(v) ; end
        def #{group.identifier} ; groups[#{group.identifier.inspect}] ; end
      RUBY
    end
  end
end
