module Protobuf
  module Rpc
    class Env < Hash
      # Creates an accessor that simply sets and reads a key in the hash:
      #
      #   class Config < Hash
      #     hash_accessor :app
      #   end
      #
      #   config = Config.new
      #   config.app = Foo
      #   config[:app] #=> Foo
      #
      #   config[:app] = Bar
      #   config.app #=> Bar
      #
      def self.hash_accessor(*names) #:nodoc:
        names.each do |name|
          name_str = name.to_s.freeze

          define_method name do
            self[name_str]
          end

          define_method "#{name}=" do |value|
            self[name_str] = value
          end

          define_method "#{name}?" do
            !self[name_str].nil?
          end
        end
      end

      # TODO: Add extra info about the environment (i.e. variables) and other
      # information that might be useful
      hash_accessor :client_host,
                    :encoded_request,
                    :encoded_response,
                    :log_signature,
                    :method_name,
                    :request,
                    :request_type,
                    :request_wrapper,
                    :response,
                    :response_type,
                    :response_is_error,
                    :rpc_method,
                    :rpc_service,
                    :server,
                    :service_name,
                    :worker_id

      attr_accessor :complete_cb, :failure_cb, :success_cb

      def initialize(options = {})
        merge!(options)

        self['worker_id'] = ::Thread.current.object_id.to_s(16)
      end

      # Set a complete callback on the client to return the object (self).
      #
      #   client = Client.new(:service => WidgetService)
      #   client.on_complete {|obj| ... }
      #
      def on_complete(&complete_cb)
        @complete_cb = complete_cb
      end

      def on_complete=(callable)
        if !callable.nil? && !callable.respond_to?(:call) && callable.arity != 1
          fail "callable must take a single argument and respond to :call"
        end

        @complete_cb = callable
      end

      # Set a failure callback on the client to return the
      # error returned by the service, if any. If this callback
      # is called, success_cb will NOT be called.
      #
      #   client = Client.new(:service => WidgetService)
      #   client.on_failure {|err| ... }
      #
      def on_failure(&failure_cb)
        @failure_cb = failure_cb
      end

      def on_failure=(callable)
        if !callable.nil? && !callable.respond_to?(:call) && callable.arity != 1
          fail "Callable must take a single argument and respond to :call"
        end

        @failure_cb = callable
      end

      # Set a success callback on the client to return the
      # successful response from the service when it is returned.
      # If this callback is called, failure_cb will NOT be called.
      #
      #   client = Client.new(:service => WidgetService)
      #   client.on_success {|res| ... }
      #
      def on_success(&success_cb)
        @success_cb = success_cb
      end

      def on_success=(callable)
        if !callable.nil? && !callable.respond_to?(:call) && callable.arity != 1
          fail "Callable must take a single argument and respond to :call"
        end

        @success_cb = callable
      end
    end
  end
end
