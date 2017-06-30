require 'spec_helper'
require 'contextualizer'

describe Contextualizer do
  describe 'when extending a class' do
    let(:klass) { Class.new.extend(Contextualizer) }

    it "defines a 'initialize' method which ignores params" do
      expect(klass.new().context).to eq({})
      expect(klass.new({}).context).to eq({})
    end

    context 'with defined context params' do
      let(:klass) do
        Class.new do
          extend Contextualizer
          context :foo, :bar, quz: 'QUZ'
        end
      end

      let(:object) { klass.new(foo: 'FOO', bar: 'BAR', quz: 'CORGE', qux: 'QUX') }

      it "defines 'initialize' method" do
        expect(object.foo).to eq('FOO')
        expect(object.bar).to eq('BAR')
        expect(object.quz).to eq('CORGE')
      end

      it "defines a 'context' method with the passed values", :aggregate_failures do
        expect(object.context).to eq(foo: 'FOO', bar: 'BAR', quz: 'CORGE')
        expect(object.context).to be_frozen
      end

      context 'and initializing without a non default value' do
        it 'raise an error' do
          expect { klass.new(foo: 'FOO') }.to raise_error.
            with_message(':bar was not found in scope')
        end
      end

      context 'and initializing without a default value' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR') }

        it 'sets correct values' do
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUZ')
        end
      end

      context 'and initializing using nil as value' do
        let(:object) { klass.new(foo: nil, bar: 'BAR') }

        it 'sets correct values' do
          expect(object.foo).to eq(nil)
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUZ')
        end
      end

      context 'and initializing using false as value' do
        let(:object) { klass.new(foo: false, bar: 'BAR') }

        it 'sets correct values' do
          expect(object.foo).to eq(false)
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUZ')
        end
      end

      context 'and overriding a default value using nil' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR', quz: nil) }

        it 'sets correct values' do
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq(nil)
        end
      end

      context 'and inheriting from that class' do
        let(:subclass) do
          Class.new(klass) do
            context :baz, quux: 'QUUX'
          end
        end

        let(:object) { subclass.new(foo: 'FOO', bar: 'BAR', baz: 'BAZ', quz: 'CORGE', qux: 'QUX') }

        it 'uses the new defined params and former ones', :aggregate_failures do
          expect(object.context).to eq(foo: 'FOO', bar: 'BAR', baz: 'BAZ', quz: 'CORGE',
                                       quux: 'QUUX')

          expect { subclass.new(foo: 'FOO', bar: 'BAR') }.to raise_error.
            with_message(':baz was not found in scope')
        end
      end
    end

  end
end
