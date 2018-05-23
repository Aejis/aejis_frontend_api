module FrontendApi
  module Commands
    module Users
      #
      class Create
        include Adapters::Mixin
        include Result::Mixin

        def self.call(attrs)
          new(attrs).call
        end

        def call
          Save.call(User.new, @attrs)
        end

      private

        def initialize(attrs)
          @attrs = attrs
        end
      end
    end
  end
end
