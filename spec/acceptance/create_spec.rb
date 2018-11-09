require 'spec_helper'
include ImageHelper

RSpec.describe 'Create' do
  context 'when valid' do
    before { post('/users', params) }
    let(:params) { User.new(name: 'Create').to_hash }

    it 'should create' do
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match_response_schema('users/show')
    end
  end

  context 'when invalid' do
    before { post('/users', params) }
    let(:params) { {} }
    it { expect(last_response.status).to eq(422) }
  end

  context 'image uploading' do
    before do
      multipart(:post, '/users', params, files)
    end

    let(:params) { User.new(name: 'ImageCreate').to_hash }

    let(:files) do
      ['image'].map { |attr| [attr, uploaded_file('img.jpg')] }.to_h
    end

    ['image'].each do |attr|
      it "should upload the #{attr}" do
        expect(last_response.status).to eq(200)
        expect(User[JSON.parse(last_response.body)['data']['id']].send(:"#{attr}?")).to be_truthy
      end
    end
  end
end
