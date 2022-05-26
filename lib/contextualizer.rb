require 'contextualizer/version'

module Contextualizer
  OPTIONAL = Object.new.freeze

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
        mod.send(:define_method, :initialize) do |ctx = {}|
          super(ctx)
          setter.set(self, ctx)
        end
      else
        mod.send(:define_method, :initialize) do |ctx = {}|
          super()
          setter.set(self, ctx)
        end
      end
    end
  end

  class Setter
    def initialize
      @mandatory, @with_default, @optional = [], {}, []
    end

    def add_attrs(*attrs, **opt_attrs)
      optional, with_default = opt_attrs.partition { |_, v| v == OPTIONAL }.map(&:to_h)

      @mandatory |= attrs
      @optional |= optional.keys
      @with_default.merge!(with_default)
    end

    def set(obj, ctx)
      context = obj.context&.dup || {}

      @with_default.each { |key, default| context[key] = ctx.fetch(key, default) }
      @optional.each { |key| context[key] = ctx[key] if ctx.key?(key) }
      @mandatory.each do |key|
        fail ":#{key} was not found in scope" unless ctx.key?(key)
        context[key] = ctx[key]
      end

      context.each do |attr, value|
        obj.instance_variable_set :"@#{attr}", value
      end

      obj.instance_variable_set(:@context, context.freeze)
    end
  end
end
