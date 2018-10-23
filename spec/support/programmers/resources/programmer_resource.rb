module FrontendApi
  class ProgrammerResource < Resource
    scope readonly: true do
      attribute :id
    end

    attribute :php do |programmer, opts|
      opts[:vegan] == 'true' ? true : false
    end
  end
end
