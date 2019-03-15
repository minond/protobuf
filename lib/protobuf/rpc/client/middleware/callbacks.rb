module Protobuf
  module Rpc
    module Middleware
      module Client
        class Callbacks
          include Protobuf::Logging

          def initialize(app)
            @app = app
          end

          def call(env)
            begin
              if env.response_is_error then
                logger.debug { sign_message("Server succeeded request (invoking on_success)") }
                env.failure_cb.call(env.response) unless env.failure_cb.nil?
              else
                logger.debug { sign_message("Server failed request (invoking on_failure): #{env.response.inspect}") }
                env.success_cb.call(env.response) unless env.success_cb.nil?
              end
            rescue => e
              logger.error { sign_message("Callback error encountered") }
              log_exception(e)
            ensure
              logger.debug { sign_message('Response processing complete') }
              env.complete_cb.call(env) unless env.complete_cb.nil?
            end

            @app.call(env)
          end
        end
      end
    end
  end
end
