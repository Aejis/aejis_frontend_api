module FrontendApi
  module Commands
    ##
    # Command interface + basic implementation
    #
    module Basic
      # :nocov:
      def call(*)
        raise NotImplementedError
      end

      def result
        raise NotImplementedError
      end
      # :nocov:

      def errors
        @errors.select { |_, v| v&.any? }
      end

      def warnings
        @warnings.select { |_, v| v&.any? }
      end

      def success?
        errors.none?
      end
    end
  end
end
