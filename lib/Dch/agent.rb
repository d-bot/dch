module Dch
	class Ping
    include 'logger'
    attr_reader :rtt
    def initialize(domain)
      @target = domain
    end

    def fping(option={})
      res = `fping -q -c 5 #{@target.join(' ')} 2>&1 | awk '{print $1,$8}' | xargs`.split
    end

    def pingable?(domain)
      ping_flag ||= nil

      !!ping_flag
    end
	end

	class Curl

		attr_reader :http_code, :dns_lookup, :conn_time, :ttfb, :time_to_total

		def initialize(url, r_byte, &block)
			curl_cmd = %Q{ curl -s -D- -r 0-#{r_byte} -o /dev/null -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2)" -w "%{http_code} DNSLookup: %{time_namelookup} Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total}" #{url}; echo }

		end

		def rtt

		end

	end
end
