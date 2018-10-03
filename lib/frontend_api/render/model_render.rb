module FrontendApi
  module Render
    module Model
      include BaseRender

      # Overwrite in controllers to change `:include` option for serialization.
      def includes
        params[:include]&.split(',')
      end

      # Overwrite in controllers to change `:include` option
      # for serialization of a collection.
      def collection_includes
        includes
      end

      # Overwrite in controllers to change `:include` option
      # for serialization of a single model.
      def member_includes
        includes
      end

      ##
      # Method responsible for proper json rendering of a model.
      # Renders a model or results in 404 Not Found if the model is nil.
      # nil is not a model class thus can not be rendered.
      def render_model(model)
        if model
          render json: serialize_model(model)
        else
          head :not_found
        end
      end

      ##
      # Method responsible for proper json rendering of a collection of models.
      # Renders a collection of models.
      # Empty collection is still a valid collection
      # thereby this method does never result in 404.
      def render_models(models)
        render json: serialize_models(models)
      end

      def serialize_model(model, options = {})
        options[:include] ||= member_includes
        options[:meta] ||= {}
        options[:current_user] ||= current_user if respond_to?(:current_user) && current_user
        serializer_for_model(model.model).serialize(model, options)
      end

      def serialize_models(models, options = {})
        options[:include] ||= collection_includes
        options[:meta] ||= true if params['for_list'] == 'true'
        options[:current_user] ||= current_user if respond_to?(:current_user) && current_user
        serializer_for_model(models.model).serialize(models, options)
      end

      # Classes which include RenderHelper should implement this method.
      # The method should return serializer class which implements .serialize(object, opts) method.
      # :nocov:
      def serializer_for_model(model)
        NestedConstFinder.nested_const_get(Module.nesting, "#{model.name}Serializer")
      end
      # :nocov:
    end
  end
end
