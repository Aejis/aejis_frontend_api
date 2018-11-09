require 'spec_helper'

RSpec.describe 'Update' do
  let(:id)     { user.id }
  let(:user)   { User.create(name: 'Update') }
  let(:params) { { name: 'Update1' } }

  before(:each) { put("/users/#{id}", params) }

  it 'should update' do
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match_response_schema('users/show')
    params.each { |e, a| expect(User[JSON.parse(last_response.body)['data']['id']][e]).to eq(a) }
  end

  context 'when invalid' do
    let(:params) { { name: nil } }
    it 'should respond with 422' do
      expect(last_response.status).to eq(422)
    end
  end

  context 'when does not exist' do
    let(:id) { 0 }

    it 'should respond with 404' do
      expect(last_response.status).to eq(404)
    end
  end
end
