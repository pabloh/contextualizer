# frozen_string_literal: true

require "contextualizer"

module Contextualizer
  module Callable
    def call(ctx,...)
      new(ctx).call(...)
    end

    def self.extended(klass)
      klass.extend Contextualizer
    end
  end
end
