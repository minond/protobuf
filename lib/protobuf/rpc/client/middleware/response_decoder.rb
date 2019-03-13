module Protobuf
  module Rpc
    module Middleware
      module Client
        class ResponseDecoder
          include Protobuf::Logging

          def initialize(app)
            @app = app
          end

          def call(env)
            env.response = decode_response(env.response_type, env.encoded_response)
            @app.call(env)
            env
          end

          def decode_response(response_type, response_data)
            response_wrapper = ::Protobuf::Socketrpc::Response.decode(response_data)

            # Determine success or failure based on parsed data
            if response_wrapper.field?(:error_reason)
              logger.debug { sign_message("Error response parsed") }

              # Fail the call if we already know the client is failed. Don't
              # try to parse out the response payload
              error(response_wrapper.error_reason, response_wrapper.error)
            else
              logger.debug { sign_message("Successful response parsed") }

              # Ensure client_response is an instance of the response type
              parsed = response_type.decode(response_wrapper.response_proto.to_s)

              if parsed.nil?
                error(:BAD_RESPONSE_PROTO, "Unable to parse response from server")
              else
                parsed
              end
            end
          end

          def error(code, message)
            error = ClientError.new
            error.code = ::Protobuf::Socketrpc::ErrorReason.fetch(code)
            error.message = message
            error
          end
        end
      end
    end
  end
end
