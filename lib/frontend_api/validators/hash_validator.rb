require 'ostruct'

module FrontendApi
  ##
  # Makes it possible to use Validator DSL over a Hash.
  #
  class HashValidator < ModelValidator
  private

    def initialize(hash, *attrs)
      super(OpenStruct.new(hash))
    end
  end
end
