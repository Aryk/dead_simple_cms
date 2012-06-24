module DeadSimpleCMS
  # Public: A Group is essentially an Attribute::Collection with the ability to have it's own groups on it with infinite
  # nesting of groups.
  class Group < Attribute::Collection

    ROOT_IDENTIFIER = :root

    attr_reader :groups, :presenter_class, :render_proc

    def initialize(identifier, options={})
      @groups = DeadSimpleCMS::Group.new_dictionary
      super
    end

    def self.root
      new(ROOT_IDENTIFIER)
    end

    # Public: Set different mechanisms for rendering this group.
    def display(presenter_class=nil, &block)
      @presenter_class = presenter_class
      @render_proc = block
    end

    # Public: If a presenter class was specified, returns an instance of the presenter.
    def presenter(view_context, *args)
      @presenter_class.new(view_context, *args) if @presenter_class
    end

    # Public: Render the group using the passed in proc in the scope of the template.
    def render(view_context, *args)
      if @render_proc
        view_context.instance_exec(self, *args, &@render_proc)
      elsif presenter = presenter(view_context, self, *args)
        presenter.render
      end
    end

    def root?
      identifier == ROOT_IDENTIFIER
    end

    def add_group(group)
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
