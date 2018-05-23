require 'spec_helper'

RSpec.describe 'Show' do
  let(:id)   { user.id }
  let(:user) { User.create(name: 'Show') }

  before(:each) { get("/users/#{id}") }

  it 'should match response schema users/show' do
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match_response_schema('users/show')
    expect(JSON.parse(last_response.body)['data']['id']).to eq(user.id)
  end

  context 'when does not exist' do
    let(:id) { 0 }

    it 'should respond with 404' do
      expect(last_response.status).to eq(404)
    end
  end
end
