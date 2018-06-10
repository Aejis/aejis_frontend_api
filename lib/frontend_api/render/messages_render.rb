module FrontendApi
  module Render
    module Messages
      def update_message
        "#{entity_name} has been updated successfully."
      end

      def create_message
        "#{entity_name} has been created successfully."
      end

      def duplicate_message
        "#{entity_name} has been duplicated successfully."
      end

      def destroy_message
        "#{entity_name} has been deleted successfully."
      end

      def publish_message
        "#{entity_name} has been published successfully."
      end

      def draft_message
        "#{entity_name} has been put to drafts successfully."
      end

      def archive_message
        "#{entity_name} has been archived successfully."
      end

      def unarchive_message
        "#{entity_name} has been unarchived successfully."
      end

      def schedule_message
        "#{entity_name} has been scheduled successfully."
      end

      def action_message
        send :"#{request.request_method.downcase}_message" if respond_to?(:"#{request.request_method.downcase}_message")
      end

      def entity_name
        'Object'
      end
    end
  end
end
