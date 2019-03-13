module Protobuf
  module Rpc
    module Middleware
      module Client
        class Logger
          include Protobuf::Logging

          def initialize(app)
            @app = app
          end

          def call(env)
            dup._call(env)
          end

          def _call(env)
            logger.debug { sign_message("#{env.service_name}##{env.method_name}") }
            logger.debug { sign_message("Request Type: #{env.request_type.name}") }
            logger.debug { sign_message("Response Type: #{env.response_type.name}") }
            logger.debug { sign_message("Request Data: #{env.request.inspect}") }

            @app.call(env)
          end
        end
      end
    end
  end
end
