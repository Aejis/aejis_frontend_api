module FrontendApi
  class UserValidator < ResourceValidator
    validates :presence, %i[name]
    validates :uniqueness, %i[name]
    validates :positive, :position, Integer, if: -> { @user.position }
  end
end
