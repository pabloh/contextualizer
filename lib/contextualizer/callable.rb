require 'contextualizer'
require 'ruby2_keywords'

module Contextualizer
  module Callable
    ruby2_keywords def call(ctx, *args, &bl)
      new(ctx).call(*args, &bl)
    end

    def self.extended(klass)
      klass.extend Contextualizer
    end
  end
end
