module FrontendApi
  module Commands
    module FilesUploading
    private

      # passes values of {type: :file} attributes through upload handlers
      def upload_files(model)
        resource_class.find_attributes(writable: true, type: :file).each do |attr, opts|
          next unless @attrs.key?(attr)
          if @attrs[attr].present?
            opts[:uploader].upload(model, attr, @attrs[attr])
          else
            opts[:uploader].remove(model, attr)
          end
        end
      end
    end
  end
end
