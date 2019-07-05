module FrontendApi
  class UserValidator < ResourceValidator
    validates :presence, %i[name]
    validates :uniqueness, %i[name]
    validates :positive, :position, Integer, if: -> { @user.position }
    validates :max_length, :name, 16, if: -> {@user.name}
  end
end
