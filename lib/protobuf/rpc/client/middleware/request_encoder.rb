module Protobuf
  module Rpc
    module Middleware
      module Client
        class RequestEncoder
          def initialize(app)
            @app = app
          end

          def call(env)
            env.encoded_request = ::Protobuf::Socketrpc::Request.encode(env.request_wrapper)
            @app.call(env)
            env
          end
        end
      end
    end
  end
end
