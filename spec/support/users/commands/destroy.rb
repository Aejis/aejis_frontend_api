module FrontendApi
  module Commands
    module Users
      #
      class Destroy
        include Result::Mixin

        def self.call(user)
          new(user).call
        end

        def call
          @user.destroy
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
