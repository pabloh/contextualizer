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

    let(:klass_with_kwargs) do
      Class.new do
        extend Callable
        context :foo, :bar

        def call(times, offset:)
          context[:foo] * times + offset
        end
      end
    end

    let(:context) { { foo: 99, bar: 111} }

    describe "#call" do
      it "initializes object with context and pass remaining params to 'call'" do
        expect(klass.call(context, 100)).to eq(9900)
      end

      context "when passing kwargs" do
        it "initializes object with context and pass all remaining params to 'call'" do
          expect(klass_with_kwargs.call(context, 100, offset: 77)).to eq(9977)
        end
      end
    end
  end
end
