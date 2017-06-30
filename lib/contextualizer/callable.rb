require 'contextualizer'

module Contextualizer
  module Callable
    def call(ctx, *args, &bl)
      new(ctx).call(*args, &bl)
    end

    def self.extended(klass)
      klass.extend Contextualizer
    end
  end
end
