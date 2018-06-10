require 'sinatra'
require 'support/users/commands/create'
require 'support/users/commands/destroy'
require 'support/users/commands/save'
require 'support/users/resources/user_resource'
require 'support/users/validators/user_validator'
require 'support/users/serializers/user_serializer'
require 'support/users/filters/dataset_filter'

include FrontendApi
use JSONMultipartFormData

class User < Sequel::Model
  def image?
    !image_urls.empty?
  end
end

helpers do
  def render(*args, &block)
    case (obj = args.first)
    when Sequel::Model
      render_model obj
    when Sequel::Dataset
      render_models obj
    when FrontendApi::Commands::Result
      render_command_result obj
    else
      Render::BaseRender.render_json obj
    end
  end
end

before do
  content_type :json
end

# GET /users
get '/users' do
  render DatasetFilter.new(params).filter(User.dataset)
end

# GET /users/:id
get '/users/:id' do
  render user
end

# POST /users
post '/users' do
  render Commands::Users::Create.call(params)
end

# PUT /users/:id
put '/users/:id' do
  render Commands::Users::Save.call(user, params)
end

# DELETE /users/:id
delete '/users/:id' do
  render Commands::Users::Destroy.call(user)
end

def user
  @user ||= find! User
end

def entity_name
  User.name
end
