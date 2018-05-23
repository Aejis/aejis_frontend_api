module FrontendApi
  module Commands
    module Adapters
      module Mixin
        # returns a function which transforms Validator interface into Result interface
        def Validate(validator_class)
          lambda do |object|
            validator = validator_class.new(object)
            validator.valid? ? Success(object) : Failure(validator.errors)
          end
        end

        # return a function which performs given ActiveJob with object's id
        def Job(active_job)
          lambda do |object|
            active_job.perform_later(object.id)
          end
        end
      end
    end
  end
end
