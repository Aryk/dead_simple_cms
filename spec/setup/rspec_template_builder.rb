require 'rspec'
require 'spec_helper'
require 'active_support'
require 'fileutils'

# A little helper I created to make it easier to build the rspec template files for all the classes within a namespace.
module RSpec

  def self.build_templates(*classes)
    options = classes.extract_options!

    classes.each do |klass|
      filename = "spec/#{klass.to_s.underscore}_spec.rb"
      if File.exists?(filename)
        puts "#{filename} already exists. Overwrite it? y/n"
        next unless %w{y yes}.include?(gets.strip.downcase)
      end

      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w+') { |f| TemplateBuilder.new(klass, f).build! }
    end
  end

  def self.build_templates_from_namespace(*namespaces)
    build_templates(*namespaces.map { |namespace| classes_from_namespace(namespace) }.flatten)
  end


  def self.classes_from_namespace(namespace, arr=[], original_namespace=nil)
    original_namespace ||= namespace

    namespace.constants.map(&namespace.method(:const_get)).each do |constant|
      next if arr.include?(constant) || !constant.to_s.starts_with?(original_namespace.to_s)
      arr << constant if constant.is_a?(Class)
      classes_from_namespace(constant, arr, original_namespace) if constant.is_a?(Class) || constant.is_a?(Module)
    end
    arr
  end

  class TemplateBuilder

    INDENT = "  "

    attr_reader :current_indent, :klass

    def initialize(klass, target = "")
      @klass = klass
      @target = target
      @current_indent = ""
    end

    def parse_file
      FileParse.new(filename)
    end

    def build!
      require_files
      describe(klass) do
        before_each do

        end
        klass.methods(false).each do |method_name| # class methods
          describe(%{".#{method_name}"})
        end
        klass.instance_methods(false).each do |method_name| # instance methods
          describe(%{"##{method_name}"})
        end
      end
    end

    def require_files
      w %{require "spec_helper"}, nil
    end

    def indent
      @current_indent << INDENT
      yield
    ensure
      @current_indent.gsub!(/^#{INDENT}/, '')
    end

    def before_each
      w "before(:each) do", nil, "end", nil
    end

    def describe(what, &block)
      w "describe #{what} do", nil
      indent(&block) if block_given?
      w "end", nil
    end

    # If nothing is passed in, will add one empty line.
    def write_lines(*strings)
      strings = [""] if strings.empty?
      strings.each do |s|
        line = "#{current_indent}#{s}"
        line = "" if line.empty?
        @target << "#{line}\n"
      end
    end
    alias w write_lines

  end
end