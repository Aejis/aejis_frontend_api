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
        klass[params[klass.primary_key]] or halt 404
      end

      def render_resources(resources)
        resources = resources.each_with_object({}) do |resource, h|
          model_name = resource.name.demodulize.chomp('Resource')
          filter_name = "CMS::#{model_name.classify.pluralize}Filter"
          filter = begin
            Object.const_get(filter_name)
          rescue NameError
            DatasetFilter
          end
          h[model_name.tableize] = {
            attributes: resource.attributes,
            associations: resource.associations.dup.transform_values do |v|
              v.slice(:required, :writable, :readable, :type, :resource, :attribute)
            end,
            filters: filter.filters.keys
          }
        end
        { json: resources }.to_json
      end

      def render_not_found
        render status: :not_found, json: { messages: [format_error('Object not found')] }
      end
    end
  end
end
