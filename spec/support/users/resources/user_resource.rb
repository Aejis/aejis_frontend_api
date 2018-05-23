module FrontendApi
  class UserResource < Resource
    scope readonly: true do
      attribute :id
    end

    scope required: true do
      attribute :name
    end
  end
end
