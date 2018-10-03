module FrontendApi
  class ResourceSerializer
    MissingSerializer = Class.new(StandardError)

    class << self
      def serialize(object, opts = {})
        if object.respond_to?(:map)
          serialize_models(object, opts)
        else
          serialize_model(object, opts)
        end
      end

      def serialize_models(objects, opts = {})
        return { data: [] } if !objects.respond_to?(:model) && objects.empty?
        klass = objects.respond_to?(:model) ? objects.model : objects.first.class
        resource = resource_for_model(klass)
        new(resource).serialize_models(objects, opts)
      end

      def serialize_model(object, opts = {})
        return { data: nil } unless object
        klass = object.respond_to?(:model) ? object.model : object.class
        resource = resource_for_model(klass)
        new(resource).serialize_model(object, opts)
      end

      def metas
        @metas ||= {}
      end

      # DSL method
      def meta(name, value)
        metas[name] = value
      end

      ##
      # Finds a resource for a given class.
      # This method in intended to be overwritten in subclasses if there's
      # a need of a different algorithm of looking for a resource.
      def resource_for_model(klass)
        FrontendApi::Resource.resource_for(klass.name)
      end

      ##
      # Finds a serializer for a given class.
      # This method in intended to be overwritten in subclasses if there's
      # a need of a different algorithm of looking for a serializer.
      def serializer_for_model(klass)
        name = "#{klass.name}Serializer"
        NestedConstFinder.nested_const_get(Module.nesting, name)
      rescue NameError
        self
      end
    end

    def initialize(resource_class)
      @resource_class = resource_class
    end

    def serialize_models(dataset, opts = {})
      return { data: [] } unless dataset
      records = dataset.respond_to?(:eager) ? dataset.eager(*associations).all : dataset
      data = records.map { |record| serialize_model(record, opts)&.fetch(:data) }
      return { data: data } unless opts[:meta]

      meta = dataset_meta(dataset)
      meta = meta.merge(dynamic_meta)
      meta = meta.merge(opts[:meta]) if opts[:meta].is_a?(Hash)
      { data: data, meta: meta }
    end

    def serialize_model(model, opts = {})
      return { data: nil } unless model

      serializer = self.class.serializer_for_model(model.class)
      model = @resource_class.new(model, opts)
      data = {}
      attributes.each { |attr| data[attr] = model.send(attr) }
      includes = Array(opts[:include] || []).map(&:to_sym)
      (associations & includes).each do |assoc|
        data[assoc] = serializer.serialize(model.send(assoc))&.fetch(:data)
        next unless include_in_association(assoc)
        include_in_association(assoc).each do |incl|
          if data[assoc].is_a?(Array)
            incl_serializer = NestedConstFinder.nested_const_get(Module.nesting, "#{incl.to_s.capitalize}Serializer")
            incl_array = incl_serializer.serialize(model.send(assoc).map { |entity| entity.send(incl) }.compact)&.fetch(:data)
            data[assoc] = data[assoc].each_with_index { |entity, index| entity[incl] = incl_array[index] }
          else
            data[assoc][incl] = serializer.serialize(model.send(assoc).send(incl))&.fetch(:data)
          end
        end
      end
      return { data: data } unless opts[:meta]

      meta = {}
      meta = meta.merge(opts[:meta]) if opts[:meta].is_a?(Hash)
      { data: data, meta: meta }
    end

  private

    def dataset_meta(dataset)
      {
        offset: dataset.opts[:offset],
        limit: dataset.opts[:limit],
        total: dataset.limit(nil, nil).count
      }
    end

    def dynamic_meta
      self.class.metas.each_with_object({}) do |(key, value), meta|
        value = value.call if value.respond_to?(:call)
        meta[key] = value
      end
    end

    def attributes
      @resource_class.readable_attributes.keys
    end

    def associations
      @resource_class.associations.keys
    end

    def include_in_association(assoc)
      @resource_class.associations[assoc][:include]
    end
  end
end
