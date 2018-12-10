module FrontendApi
  ##
  # Additional validations for sequel models.
  #
  class ModelValidator < ObjectValidator
  private

    # predefined validation method
    # checks that one or more attrs of Sequel::Model have unique values
    # each attr in checked individually!
    # TODO: send conditions doesn't work
    def uniqueness(attrs, conditions = nil)
      Array(attrs).each do |attr|
        next unless (value = @object.send(attr))

        dups = @object.class.dataset
        dups = dups.exclude(@object.model.primary_key => @object.pk) if @object.pk
        dups = dups.where(conditions) if conditions
        dups = dups.where(attr => value)

        error(attr, 'is already taken') unless dups.empty?
      end
    end
  end
end
