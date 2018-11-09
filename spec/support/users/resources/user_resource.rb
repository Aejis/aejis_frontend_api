module FrontendApi
  class UserResource < Resource
    scope readonly: true do
      attribute :id
    end

    scope required: true do
      attribute :name
    end

    attribute :position
    attribute :vegan do |_user, opts|
      opts[:vegan] == 'true'
    end
    # TODO: write and fix tests for association
    # association :programmers
  end
end
