module FrontendApi
  class ProgrammerResource < Resource
    scope readonly: true do
      attribute :id
    end

    attribute :php do |_programmer, opts|
      opts[:vegan] == 'true'
    end
  end
end
