module FrontendApi
  module Render
    module Command
      include Messages
      include Model
      include BaseRender

      ##
      # Method which can render a result of a Command.
      # The argument should be an object which implements Command interface:
      # #result, #success?, #errors, #warnings methods
      def render_command_result(result)
        render_result(result.result, result.success?, result.errors, result.warnings)
      end

      ##
      # Method responsible for rendering a result of an action.
      # Renders a model if `success` is not falsey or renders errors otherwise.
      # `success` can be a string in which case it becomes a success message.
      def render_result(object, success = true, errors = {}, warnings = {}, status = nil)
        if success
          render_success(object, success, **{ warnings: warnings, status: status }.compact)
        else
          render_errors(**{ errors: errors, status: status }.compact)
        end
      end

      # Internal method to render a result of a succeeded action.
      def render_success(object, success = true, warnings: [], status: 200)
        success = action_message if success.is_a?(TrueClass)
        messages = format_messages([], warnings)
        messages << { type: :success, text: success } if success.is_a?(String)

        render status: status, json: serialize_object(object, meta: { messages: messages })
      end

      # Internal method to render a result of a failed action.
      def render_errors(errors: {}, warnings: [], status: 422)
        errors = { base: errors } if errors.is_a?(Array)
        messages = format_messages(errors.fetch(:base, []), warnings)
        errors = errors.tap { |hs| hs.delete(:base) }
        if messages.empty?
          text = "#{entity_name} has not been saved: #{errors.size} error/s found!"
          messages << { type: :error, text: text }
        end

        render status: status, json: { messages: messages, errors: errors }
      end

      def format_messages(errors = [], warnings = [])
        errors.map(&method(:format_error)) + warnings.map(&method(:format_warning))
      end

      def format_error(message)
        { type: :error, text: message }
      end

      def format_warning(message)
        { type: :warning, text: message }
      end

      def serialize_object(object, options = {})
        object.respond_to?(:map) ? serialize_models(object, options) : serialize_model(object, options)
      end
    end
  end
end
