require 'spec_helper'

RSpec.describe FrontendApi::ModelValidator do
  describe '#validate' do
    let(:validator_class) do
      Class.new(described_class) do
        validates :foo, :args

      private

        def foo(args); end
      end
    end

    let(:validator) { validator_class.new(Object.new) }

    it 'calls methods defined with .validates' do
      expect(validator).to receive(:foo).with(:args)
      validator.validate
    end
  end

  describe 'built-in validations' do
    describe 'presence' do
      let(:validator_class) { Class.new(described_class) { validates :presence, :foo } }
      let(:validator) { validator_class.new(object) }
      let!(:error) { 'is required' }

      before { validator.validate }

      context 'when no method' do
        let(:object) { Object.new }

        it { expect(validator.valid?).to eq(false) }
        it { expect(validator.errors).to eq(foo: [error]) }
      end

      context 'when nil' do
        let(:object) { OpenStruct.new(foo: nil) }

        it { expect(validator.valid?).to eq(false) }
        it { expect(validator.errors).to eq(foo: [error]) }
      end

      context 'when empty string' do
        let(:object) { OpenStruct.new(foo: nil) }

        it { expect(validator.valid?).to eq(false) }
        it { expect(validator.errors).to eq(foo: [error]) }
      end

      context 'when present' do
        let(:object) { OpenStruct.new(foo: 'bar') }

        it { expect(validator.valid?).to eq(true) }
        it { expect(validator.errors).to be_empty }
      end
    end

    describe 'max_length' do
      let(:validator_class) { Class.new(described_class) { validates :max_length, :foo, :count } }
      let(:validator) { validator_class.new(object) }
      let(:count) { 5 }
      let!(:error) { "is is too long (maximum is   %{@object.send(count)}  characters)" }

      before { validator.validate }

      context 'when length is the same' do
        let(:object) { OpenStruct.new(foo: 'baris', count: count) }

        it { expect(validator.valid?).to eq(true) }
        it { expect(validator.errors).to be_empty }
      end

      context 'when length is too long' do
        let(:object) { OpenStruct.new(foo: 'barisov', count: count) }

        it { expect(validator.valid?).to eq(false) }
        it { expect(validator.errors).to eq(foo: [error]) }
      end

      context 'when length is short' do
        let(:object) { OpenStruct.new(foo: 'bar', count: count) }

        it { expect(validator.valid?).to eq(true) }
        it { expect(validator.errors).to be_empty }
      end
    end

    describe 'uniqueness' do
      before :all do
        DB.create_table :dummies do
          primary_key :id
          column :foo, :text
        end

        @model_class = Class.new(Sequel::Model) { set_dataset DB[:dummies] }
      end

      after :all do
        DB.drop_table :dummies
      end

      let(:validator_class) { Class.new(described_class) { validates :uniqueness, :foo } }
      let(:validator) { validator_class.new(object) }
      let!(:error) { 'is already taken' }

      before { validator.validate }

      context 'new object' do
        after(:all) { @model_class.dataset.delete }
        let!(:object) { @model_class.new(foo: 'bar') }

        context 'when a duplicate exists' do
          before(:context) { @model_class.create(foo: 'bar') }

          it { expect(validator.valid?).to eq(false) }
          it { expect(validator.errors).to eq(foo: [error]) }
        end

        context 'when no duplicate exists' do
          before(:context) { @model_class.dataset.delete }

          it { expect(validator.valid?).to eq(true) }
          it { expect(validator.errors).to be_empty }
        end
      end

      context 'existing object' do
        before(:each) { @model_class.dataset.delete }
        let!(:object) { @model_class.create(foo: 'bar') }

        context "doesn't count self as duplicate" do
          it { expect(validator.valid?).to eq(true) }
          it { expect(validator.errors).to be_empty }
        end
      end
    end
  end
end
