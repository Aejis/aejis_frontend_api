module FrontendApi
  class JSONMultipartFormData
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.form_data?
        request.params.each do |key, value|
          next unless json_blob?(value)
          json = JSON.parse(value[:tempfile].read)
          if json.is_a?(Hash)
            # merge json object into request params
            json.each { |k, v| request.update_param(k, v) }
            request.delete_param(key)
          else
            # add named json objects alongside request params
            request.update_param(key, json)
          end
        end
      end
      @app.call(env)
    end

  private

    def json_blob?(value)
      value.is_a?(Hash) && value[:tempfile] && value[:type] == 'application/json'
    end
  end
end
