module FrontendApi
  module Commands
    module Users
      class Destroy
        include Result::Mixin
        include PositionUpdate

        def self.call(user)
          new(user).call
        end

        def call
          @user.destroy
          destroy_position(@user)
          Success(@user)
        end

      private

        def initialize(user)
          @user = user
        end
      end
    end
  end
end
