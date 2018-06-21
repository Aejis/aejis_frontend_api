module FrontendApi
  module Commands
    module Resources
      def permitted_attrs
        settable_attrs = resource_class.writable_attributes.keys -
                         resource_class.find_attributes(type: :file).keys
        @attrs.slice(*settable_attrs)
      end

      def resource_class
        raise NotImplementedError
      end
    end
  end
end
