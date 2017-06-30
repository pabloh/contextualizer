module Contextualizer
  def context(*attrs, **opt_attrs)
    unless @_setter 
      @_setter = Setter.new
      include Contextualizer.init_for(@_setter)
    end

    @_setter.add_attrs(*attrs, **opt_attrs)
    attr_reader *attrs, *opt_attrs.keys
  end

  def self.extended(klass)
    klass.class_eval do
      attr_reader :context
      @_setter = Setter.new
      include Contextualizer.init_for(@_setter, true)
    end
  end

  def self.init_for(setter, first = false)
    Module.new do |mod|
      if first 
        mod.send(:define_method, :initialize) do |args = {}|
          super()
          setter.set(self, args)
        end
      else
        mod.send(:define_method, :initialize) do |args = {}|
          super(args)
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

      @opt_attrs.each { |key, val| context[key] = args[key] || val }
      @attrs.each { |key| context[key] = args[key] }

      context.each do |attr, value|
        fail ":#{attr} was not found in scope" if value.nil?
        obj.instance_variable_set :"@#{attr}", value
      end

      obj.instance_variable_set(:@context, context.freeze)
    end
  end
end
