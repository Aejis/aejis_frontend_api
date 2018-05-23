module FrontendApi
  module Render
    module BaseRender
      def render(parameters)
        # parameters[:json].merge!(include_entity) if parameters.is_a?(Hash) && !params[:include_entity].blank?
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

    private

      def include_entity
        entity = "CMS::#{params[:include_entity][:entity].capitalize}".classify
        dataset = Object.const_get(entity)&.dataset || {}
        filter = params[:include_entity][:params] || {}
        filter[:meta] = filter['for_list']
        included_entities = Object.const_get("#{entity.pluralize}Filter")&.new(filter)&.filter(dataset) || {}
        { include_entity: serialize_object(included_entities, filter) }
      end
    end
  end
end
