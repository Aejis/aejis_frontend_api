require 'spec_helper'

RSpec.describe 'Index' do
  let!(:users) { [User.create(name: 'Index1'), User.create(name: 'Index2')] }
  let(:params) { {} }

  before(:each) { get('/users', params) }

  it 'matches users/index schema' do
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match_response_schema('users/index')
    expect(JSON.parse(last_response.body)['data'].map { |e| e['id'] }).to contain_exactly(*users.map(&:id))
  end

  context 'for_list=true' do
    let(:params) { { for_list: 'true' } }

    it 'matches users/list schema' do
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match_response_schema('users/list')
    end
  end
end
