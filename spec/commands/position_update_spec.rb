require 'spec_helper'

RSpec.describe FrontendApi::Commands::PositionUpdate do
  describe 'Create position' do
    let(:request) { post('/users', params) }

    context 'when position set from start' do
      let(:params) { User.new(name: '1', position: 10).to_hash }

      it 'should create entity with position' do
        request
        expect(last_response.status).to eq(200)
        expect(User[JSON.parse(last_response.body)['data']['id']].position).to eq(1)
      end

      context 'when it sets bigger than max position' do
        before       { User.create(name: '1', position: 1) }
        let(:params) { User.new(name: '10', position: 10).to_hash }

        it 'should create entity with right position' do
          request
          expect(last_response.status).to eq(200)
          expect(User[JSON.parse(last_response.body)['data']['id']].position).to eq(2)
        end
      end
    end

    context 'when same position set' do
      let!(:first_entity)  { User.create(name: '1', position: 1) }
      let!(:second_entity) { User.create(name: '2', position: 2) }
      let(:params)         { User.new(name: '3', position: 1).to_hash }

      it 'should create entity with same position and increment other' do
        request
        expect(last_response.status).to eq(200)
        expect(User[JSON.parse(last_response.body)['data']['id']].position).to eq 1
        expect(first_entity.reload.position).to eq 2
        expect(second_entity.reload.position).to eq 3
      end
    end

    context 'when position empty' do
      let(:params) { User.new(name: '1', position: '').to_hash }

      it 'should create entity with position' do
        request
        expect(last_response.status).to eq(200)
        expect(User[JSON.parse(last_response.body)['data']['id']].position).to eq 1
      end
    end

    context 'when position 0 or negative' do
      let(:params) { User.new(name: '-1', position: -1).to_hash }

      it 'should return error' do
        request
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)['errors']['position'].first).to eq 'should be greater than zero'
      end
    end
  end

  describe 'Update position' do
    let(:request) { put("/users/#{id}", params) }

    context 'when same position set' do
      let!(:first_entity)  { User.create(name: '1', position: 1) }
      let!(:second_entity) { User.create(name: '2', position: 2) }
      let!(:third_entity)  { User.create(name: '3', position: 3) }
      let!(:fourth_entity) { User.create(name: '4', position: 4) }
      let(:params)         { User.new(name: '5', position: 1).to_hash }
      let(:id)             { third_entity.id }

      it 'should update entities with position' do
        request
        expect(last_response.status).to eq(200)
        expect(third_entity.reload.position).to eq 1
        expect(first_entity.reload.position).to eq 2
        expect(second_entity.reload.position).to eq 3
        expect(fourth_entity.reload.position).to eq 4
      end

      context 'when change position of nearest elements' do
        let(:id) { second_entity.id }

        it 'should update entities with position' do
          request
          expect(last_response.status).to eq(200)
          expect(second_entity.reload.position).to eq 1
          expect(first_entity.reload.position).to eq 2
          expect(third_entity.reload.position).to eq 3
          expect(fourth_entity.reload.position).to eq 4
        end
      end

      context 'when change position from first to last' do
        let(:params) { User.new(name: '6', position: 4).to_hash }
        let(:id)     { first_entity.id }

        it 'should update entities with position' do
          request
          expect(last_response.status).to eq(200)
          expect(second_entity.reload.position).to eq 1
          expect(third_entity.reload.position).to eq 2
          expect(fourth_entity.reload.position).to eq 3
          expect(first_entity.reload.position).to eq 4
        end
      end

      context 'when change position from last to first' do
        let(:params) { User.new(name: '7', position: 1).to_hash }
        let(:id)     { fourth_entity.id }

        it 'should update entities with position' do
          request
          expect(last_response.status).to eq(200)
          expect(fourth_entity.reload.position).to eq 1
          expect(first_entity.reload.position).to eq 2
          expect(second_entity.reload.position).to eq 3
          expect(third_entity.reload.position).to eq 4
        end
      end

      context 'when change position to max + 2' do
        let(:params) { User.new(name: '8', position: 6).to_hash }
        let(:id)     { first_entity.id }

        it 'should update entities with position to max + 1' do
          request
          expect(last_response.status).to eq(200)
          expect(second_entity.reload.position).to eq 1
          expect(third_entity.reload.position).to eq 2
          expect(fourth_entity.reload.position).to eq 3
          expect(first_entity.reload.position).to eq 4
        end
      end
    end

    context 'when position empty' do
      let!(:entity) { User.create(name: '1', position: 1) }
      let(:params)  { User.new(name: '2', position: '').to_hash }
      let(:id)      { entity.id }

      it 'should update entity position' do
        request
        expect(last_response.status).to eq(200)
        expect(entity.reload.position).to eq 1
      end
    end
  end

  describe 'Delete position' do
    let(:request) { delete("/users/#{id}") }

    let!(:first_entity)  { User.create(name: '1', position: 1) }
    let!(:second_entity) { User.create(name: '2', position: 2) }
    let!(:third_entity)  { User.create(name: '3', position: 3) }
    let(:id)             { second_entity.id }

    it 'should destroy entity and update position in other entities' do
      request
      expect(last_response.status).to eq(200)
      expect(first_entity.reload.position).to eq 1
      expect(third_entity.reload.position).to eq 2
    end
  end
end
