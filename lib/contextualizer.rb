require 'contextualizer/version'

module Contextualizer
  def context(*attrs, **opt_attrs)
    unless @__setter
      @__setter = Setter.new
      include Contextualizer.init_for(@__setter)
    end

    @__setter.add_attrs(*attrs, **opt_attrs)
    attr_reader *attrs, *opt_attrs.keys
  end

  def self.extended(klass)
    klass.class_eval do
      attr_reader :context
      @__setter = Setter.new
      include Contextualizer.init_for(@__setter, false)
    end
  end

  def self.init_for(setter, inherited = true)
    Module.new do |mod|
      if inherited
        mod.send(:define_method, :initialize) do |args = {}|
          super(args)
          setter.set(self, args)
        end
      else
        mod.send(:define_method, :initialize) do |args = {}|
          super()
          setter.set(self, args)
        end
      end
    end
  end

  class Setter
    def initialize
      @attrs, @opt_attrs = [], {}
    end

    def add_attrs(*attrs, **opt_attrs)
      @attrs |= attrs
      @opt_attrs.merge!(opt_attrs)
    end

    def set(obj, args)
      context = obj.context&.dup || {}

      @opt_attrs.each { |key, default| context[key] = args.key?(key) ? args[key] : default }
      @attrs.each do |key|
        fail ":#{key} was not found in scope" unless args.key?(key)
        context[key] = args[key]
      end

      context.each do |attr, value|
        obj.instance_variable_set :"@#{attr}", value
      end

      obj.instance_variable_set(:@context, context.freeze)
    end
  end
end
