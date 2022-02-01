require 'contextualizer'

module Contextualizer
  module Callable
    def call(ctx, *args, **kwargs, &bl)
      new(ctx).call(*args, **kwargs, &bl)
    end

    def self.extended(klass)
      klass.extend Contextualizer
    end
  end
end
