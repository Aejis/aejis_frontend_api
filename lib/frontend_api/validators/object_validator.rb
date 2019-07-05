module FrontendApi
  ##
  # Simple object validator.
  # Just makes it easy to define each validation separately
  # allowing adding more in subclasses/extensions.
  #
  class ObjectValidator
    attr_reader :errors

    class << self
      def validations
        @validations ||= []
      end

      # DSL method
      # Adds a validation by given method.
      # The method should be an instance method of the validator.
      def validates(method, *args, **opts)
        validations << [method, args, opts]
      end
    end

    def initialize(object, attrs=[])
      @errors = {}
      @object = object
      @attrs = attrs
    end

    # Executes validation process.
    # Doesn't return anything useful. Use #errors to check the result of validation.
    def validate
      self.class.validations.each do |(method, args, opts)|
        send(method, *args) if !opts[:if] || instance_exec(&opts[:if])
      end
    end

    # Forces validation and returns true if there are no validation errors.
    def valid?
      validate
      @errors.empty?
    end

  private

    # predefined validation method
    # checks for presence of one or more attrs
    def presence(attrs)
      Array(attrs).each do |attr|
        value = @object.respond_to?(attr) ? @object.send(attr) : nil
        # TODO: write some tests
        # consider explicit `false` as an actual value (not blank)
        error(attr, 'is required') unless value == false || value && value != ''
      end
    end

    # predefined validation method
    # checks that attr value belongs to a given array
    def inclusion(attrs, array)
      Array(attrs).each do |attr|
        error(attr, "should be one of #{array}") unless array.include?(@object.send(attr))
      end
    end

    # predefined validation method
    # checks that attr value is a positive numeric value
    # includes numeric type check for convenience
    def positive(attrs, klass = nil)
      numeric(attrs, klass) if klass
      Array(attrs).each do |attr|
        # invalid numbers convert to 0.0 and fail validation automatically
        error(attr, 'should be greater than zero') unless @object.send(attr).to_f.positive?
      end
    end

    # predefined validation method
    # checks that attr value is numeric of given type
    def numeric(attrs, klass = Integer)
      unless [Integer, Float].include?(klass)
        raise ArgumentError, 'Either Integer or Float allowed for #numeric validation'
      end

      Array(attrs).each do |attr|

        # the same as
        #   val = Integer(@object.send(attr))
        # for klass = Integer
        Object.method(klass.name).call(@object.send(attr))
      rescue ArgumentError, TypeError
        error(attr, "should be #{klass.name}")

      end
    end

    # predefined validation method
    # checks that length of attr value is not longer then given number
    def max_length(attrs, count)
      Array(attrs).each do |attr|
        error(attr, "is is too long (maximum is   %{@object.send(count)}  characters)") if @object.send(attr).size > @object.send(count)
      end
    end

    # predefined validation method
    # checks that the value is a file of any of given MIME types, subtypes, mediatypes
    # @see MimeMagic for details
    def mime(attrs, *mimes)
      mimes = mimes.map(&:to_s)
      Array(attrs).each do |attr|
        magic = MimeMagic.by_magic(@object.send(attr))
        unless magic && (mimes & [magic.type, magic.mediatype, magic.subtype]).any?
          error(attr, "should be of type #{mimes.join(' or ')}")
        end
      end
    end

    # helper method
    # adds and error for the given attribute.
    # general errors go to :base attribute.
    def error(attr, text)
      errors[attr] ||= []
      errors[attr] << text
    end

    # helper method
    # checks if given value can be considered an URL
    def url?(url)
      url = begin
              URI.parse(url)
            rescue StandardError
              false
            end
      url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
    end
  end
end
