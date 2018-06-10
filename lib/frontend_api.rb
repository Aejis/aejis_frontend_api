require 'frontend_api/version'
require 'frontend_api/json_multipart_form_data'

require 'frontend_api/validators/object_validator'
require 'frontend_api/validators/model_validator'
require 'frontend_api/validators/hash_validator'
require 'frontend_api/validators/resource_validator'

require 'frontend_api/commands/adapters'
require 'frontend_api/commands/basic'
require 'frontend_api/commands/files_uploading'
require 'frontend_api/commands/position_update'
require 'frontend_api/commands/result'
require 'frontend_api/commands/validation'
require 'frontend_api/commands/resources'
require 'frontend_api/commands/save_changes'

require 'frontend_api/resources/resource'

require 'frontend_api/serializers/resource_serializer'

require 'frontend_api/render/base_render'
require 'frontend_api/render/messages_render'
require 'frontend_api/render/model_render'
require 'frontend_api/render/command_render'

module FrontendApi
  include Render::Model
  include Render::Command
end
