require 'spec_helper'
require 'contextualizer/callable'

module Contextualizer
  describe Callable do
    let(:klass) do
      Class.new do
        extend Callable
        context :foo, :bar

        def call(times)
          context[:foo] * times
        end
      end
    end

    let(:context) { { foo: 99, bar: 111} }

    describe "#call" do
      it "initializes object with context and pass remaining params to 'call'" do
        expect(klass.call(context, 100)).to eq(9900)
      end
    end
  end
end
