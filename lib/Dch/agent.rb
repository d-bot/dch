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

		attr_reader :http_code, :dns_lookup, :tcp_handshake, :tls_handshake, :first_byte, :time_to_total

		def initialize(url, r_byte, &block)
			fqdn = url.split('/')[2]
			curl = %Q{ curl -I -s -o /dev/null -H "Host: #{fqdn}" -H "Accept-Encoding: gzip, deflate" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2)" -w "DNSLookup: %{time_namelookup} Handshake: %{time_connect} TLSHandshake: %{time_appconnect} TTFB: %{time_starttransfer} Total: %{time_total}" #{url} | cut -d ' ' -f2,4,6,8,10 }

		end

		def rtt

		end

	end
end
