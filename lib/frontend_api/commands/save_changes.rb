module FrontendApi
  module Commands
    class SaveChanges
      class << self
        include Result::Mixin

        def call(object)
          # expect the object to be valid for save by default
          # hard failure on save error
          object.save_changes(raise_on_failure: true)
          Success(object)
        rescue Sequel::Plugins::OptimisticLocking::Error
          Failure(base: ['You form is outdated, refresh the page and try again'])
        end
      end
    end
  end
end
