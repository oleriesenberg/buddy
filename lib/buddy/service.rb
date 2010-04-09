module Buddy
  module Service
    class << self
      def call(api_method, params = {}, options = {})
        begin
          application = options[:app] || 'default'
        rescue NoMethodError => e
          raise ArgumentError.new("app not specified in buddy.yml")
        end

        result = nil
        time = Benchmark.realtime do
          result = MiniFB.call(Buddy.buddy_config[application]["api_key"],
            Buddy.buddy_config[application]["secret"],
            api_method,
            params.stringify_keys)
        end
        Buddy.logger.info("Calling #{api_method} (#{params.inspect}) - #{time}")
        result
      end
    end
  end
end
