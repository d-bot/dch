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
end

