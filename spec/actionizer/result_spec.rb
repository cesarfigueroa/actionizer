require 'spec_helper'

module Actionizer
  describe Result do
    subject { described_class.new(initial_hash) }
    let(:initial_hash) { { foo: 'value' } }

    describe '#initialize' do
      it 'defaults to being successful' do
        expect(subject).to be_success
      end

      it 'allows you to pass a hash' do
        expect(subject.foo).to eq(initial_hash[:foo])
      end

      context 'when initialized with non-symbol keys' do
        let(:value) { 'some_value' }
        let(:initial_hash) { { 'string_key' => value } }

        it 'allows indifferent access' do
          expect(subject.string_key).to eq(value)
          expect(subject['string_key']).to eq(value)
          expect(subject[:string_key]).to eq(value)
        end
      end

      context 'when initialized with nested Hashes' do
        let(:initial_hash) { { foo: { ima: 'hash' } } }

        it 'leaves them as Hashes' do
          expect(subject.foo).to be_a(Hash)
        end
      end
    end

    it 'has a success? method' do
      expect(subject).to respond_to(:success?)
    end

    it 'has a failure? method' do
      expect(subject).to respond_to(:failure?)
    end

    describe '#to_h' do
      it 'works as expected' do
        expect(subject.to_h).to eq(initial_hash)
      end

      context 'when initialized with top-level non-symbol keys' do
        let(:initial_hash) { { 'string_key' => 'val', symbol_key: 'val' } }
        let(:modified_hash) { { string_key: 'val', symbol_key: 'val' } }

        it 'coerces top-level keys to be symbols' do
          expect(subject.to_h).to eq(modified_hash)
        end
      end

      context 'when initialized with nested non-symbol keys' do
        let(:initial_hash) do
          { top_level: { sym_key: 'a', 'string_key' => 'b', 123 => 'c' } }
        end

        it 'does not modify the nested keys' do
          expect(subject.to_h).to eq(initial_hash)
        end
      end
    end

    describe '#fail' do
      it 'changes the state to be failure' do
        expect(subject).to be_success
        subject.fail
        expect(subject).to be_failure
      end
    end

    it 'allows arbitrary fields to be set' do
      subject.field = 'value'
      expect(subject.field).to eq('value')
    end
  end
end
