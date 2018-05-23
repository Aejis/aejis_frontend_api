module FrontendApi
  module Commands
    module Users
      #
      class Save
        include Adapters::Mixin
        include Result::Mixin
        include Resources

        def self.call(user, attrs)
          new(user, attrs).call
        end

        def call
          Result(@user)
            .tap(method(:update_attrs))
            .then(Validate(UserValidator))
            .then(SaveChanges)
        end

        def resource_class
          UserResource
        end

      private

        def initialize(user, attrs)
          @user = user
          @attrs = attrs
        end

        def update_attrs(user)
          user.set(permitted_attrs)
        end
      end
    end
  end
end
