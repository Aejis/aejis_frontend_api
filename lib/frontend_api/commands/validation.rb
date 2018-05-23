module FrontendApi
  module Commands
    module Validation
    private

      def validate
        validator.validate
        @errors.merge!(validator.errors)
      end

      def validator
        @validator ||= model_validator
      end

      def model_validator
        const = "#{model_class.name}Validator"
        klass = NestedConstFinder.nested_const_get(Module.nesting, const)
        klass.new(model)
      end
    end
  end
end
