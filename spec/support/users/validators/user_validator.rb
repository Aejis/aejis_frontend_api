module FrontendApi
  class UserValidator < ResourceValidator
    validates :presence, %i[name]
    validates :uniqueness, %i[name]
  end
end
