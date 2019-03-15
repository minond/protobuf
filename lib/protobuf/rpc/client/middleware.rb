require 'middleware'
require 'middleware/runner'

require 'protobuf/rpc/client/middleware/callbacks'
require 'protobuf/rpc/client/middleware/logger'
require 'protobuf/rpc/client/middleware/request_encoder'
require 'protobuf/rpc/client/middleware/response_decoder'

module Protobuf
  module Rpc
    def self.client_middleware
      @client_middleware ||= ::Middleware::Builder.new(:runner_class => ::Middleware::Runner)
    end

    # Ensure the middleware stack is initialized
    client_middleware
  end

  Rpc.client_middleware.use(::Protobuf::Rpc::Middleware::Client::Logger)
  Rpc.client_middleware.use(::Protobuf::Rpc::Middleware::Client::RequestEncoder)
  Rpc.client_middleware.use(::Protobuf::Rpc::Middleware::Client::ResponseDecoder)
  Rpc.client_middleware.use(::Protobuf::Rpc::Middleware::Client::Callbacks)

  ActiveSupport.run_load_hooks(:protobuf_rpc_client_middleware, Rpc)
end
