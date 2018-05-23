module FrontendApi
  module Commands
    #
    # Command's Result for commands execution flow control
    #
    # somewhat of an Either monad
    # pure monad doesn't play well in non-functional programming
    # this module just does what it does to make the code clean and simple
    # it may so happen it's a monad, but it's not the intention
    class Result
      # monad unit function
      # Result.new(42)
      def initialize(value)
        @value = value
      end

      # monad bind function
      # Success.new(42).then { |a| Success.new(a * 2) } == Success.new(84)
      # @return [Result]
      def then(callable = ->(v) { yield v })
        callable.call(@value)
      end

      # monad join function
      # Success.new(42).result == 42
      def result
        self.then(->(v) { v })
      end

      # ruby's Object#tap over the value
      # basically no functional analogue
      # @return [Result]
      def tap(callable = ->(v) { yield v })
        self.then(callable)
        self
      end

      def ==(other)
        @value == other.instance_variable_get(:@value)
      end

      alias eql? ==

      # A Successful Result
      class Success < Result
        def success?
          true
        end

        def errors
          {}
        end

        def warnings
          {}
        end
      end

      # A Failure Result
      class Failure < Result
        def then(*)
          self
        end

        def success?
          false
        end

        def errors
          @value
        end

        def warnings
          {}
        end
      end

      module Mixin
        def Success(value)
          Success.new(value)
        end

        def Failure(value)
          Failure.new(value)
        end

        def Result(value)
          value ? Success(value) : Failure(value)
        end
      end
    end
  end
end
