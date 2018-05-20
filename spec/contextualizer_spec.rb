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
          context :foo, :bar, quz: 'QUZ', baz: Contextualizer::OPTIONAL
        end
      end

      let(:object) { klass.new(foo: 'FOO', bar: 'BAR', quz: 'CORGE', qux: 'QUX', baz: 'BAZZ') }

      it "defines 'initialize' method" do
        expect(object.foo).to eq('FOO')
        expect(object.bar).to eq('BAR')
        expect(object.quz).to eq('CORGE')
        expect(object.baz).to eq('BAZZ')
      end

      it "defines a 'context' method with the passed values", :aggregate_failures do
        expect(object.context).to eq(foo: 'FOO', bar: 'BAR', quz: 'CORGE', baz: 'BAZZ')
        expect(object.context).to be_frozen
      end

      context 'and initializing without a non default value' do
        it 'raise an error' do
          expect { klass.new(foo: 'FOO') }.to raise_error.
            with_message(':bar was not found in scope')
        end
      end

      context 'and initializing without a default value' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR', baz: 'BAZZ') }

        it 'sets passed and default values' do
          expect(object.quz).to eq('QUZ')
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
          expect(object.baz).to eq('BAZZ')
        end
      end

      context 'and initializing without an optional value' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR', quz: 'QUXX') }

        it 'ignores optional and sets passed values' do
          expect(object.context).to_not include(:baz)

          expect(object.baz).to be_nil
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUXX')
        end
      end

      context 'and initializing without optional nor default values' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR') }

        it 'sets only passed values' do
          expect(object.baz).to be_nil
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUZ')

          expect(object.context).to eq(foo: 'FOO', bar: 'BAR', quz: 'QUZ')
        end
      end

      context 'and initializing using nil as value' do
        let(:object) { klass.new(foo: nil, bar: 'BAR') }

        it 'sets nil as value' do
          expect(object.foo).to eq(nil)
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUZ')
        end
      end

      context 'and initializing using false as value' do
        let(:object) { klass.new(foo: false, bar: 'BAR') }

        it 'sets false as value' do
          expect(object.foo).to eq(false)
          expect(object.bar).to eq('BAR')
          expect(object.quz).to eq('QUZ')
        end
      end

      context 'and overriding a default value using nil' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR', quz: nil) }

        it 'sets nil instead of the default value' do
          expect(object.quz).to eq(nil)
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
        end
      end

      context 'and initializing an optional value using nil' do
        let(:object) { klass.new(foo: 'FOO', bar: 'BAR', baz: nil) }

        it 'sets nil as value' do
          expect(object.context).to include(baz: nil)

          expect(object.baz).to eq(nil)
          expect(object.foo).to eq('FOO')
          expect(object.bar).to eq('BAR')
        end
      end

      context 'and inheriting from that class' do
        let(:subclass) do
          Class.new(klass) do
            context :baaz, quux: 'QUUX'
          end
        end

        let(:object) { subclass.new(foo: 'FOO', bar: 'BAR', baz: 'BAZ', baaz: 'BAAZ', quz: 'CORGE', qux: 'QUX') }

        it 'uses the new defined params and former ones', :aggregate_failures do
          expect(object.context).to eq(foo: 'FOO', bar: 'BAR', baz: 'BAZ', baaz: 'BAAZ', quz: 'CORGE',
                                       quux: 'QUUX')

          expect { subclass.new(foo: 'FOO', bar: 'BAR') }.to raise_error.
            with_message(':baaz was not found in scope')
        end
      end
    end

  end
end
