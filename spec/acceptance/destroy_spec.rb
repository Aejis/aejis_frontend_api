require 'spec_helper'

RSpec.describe 'Destroy' do
  before(:each) { delete("/users/#{id}") }

  let(:id)   { user.id }
  let(:user) { User.create(name: 'Destroy') }

  it 'should destroy' do
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match_response_schema('users/show')
    expect(User[id]).to be_nil
  end

  context 'when does not exist' do
    let(:id) { 0 }

    it 'should respond with 404' do
      expect(last_response.status).to eq(404)
    end
  end
end
