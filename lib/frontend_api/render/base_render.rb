module FrontendApi
  module Render
    module BaseRender
      # TODO: Add include_entity
      def self.render_json(parameters)
        response = []
        response << parameters[:status] if parameters[:status]
        response.empty? ? parameters[:json].to_json : response << [parameters[:json].to_json]
      end

      def find!(klass)
        result = klass[params[klass.primary_key]]
        return result if result

        defined?(halt) ? halt(404) : raise(NestedConstFinder.nested_const_get([self.class], 'NotFoundError'))
      end

      def render_resources(resources)
        resources = resources.each_with_object({}) do |resource, h|
          model_name = resource.name.split('::').last.chomp('Resource')
          filter_name = "#{model_name.classify.pluralize}Filter"
          filter = begin
            NestedConstFinder.nested_const_get([resource.parent], filter_name)
                   rescue NameError
                     NestedConstFinder.nested_const_get([resource.parent], 'DatasetFilter')
          end
          h[model_name.tableize] = {
            attributes: resource.attributes,
            associations: resource.associations.dup.transform_values do |v|
              v.slice(:required, :writable, :readable, :type, :resource, :attribute)
            end,
            filters: filter.filters.keys
          }
        end
        render json: resources
      end
    end
  end
end
