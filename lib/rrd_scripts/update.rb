#!/usr/bin/env ruby
#
require 'logger'
log = Logger.new('/home/dchoi/projects/dch.io/logs/update.log')

rrd_dir = "/home/dchoi/projects/dch.io/public/vendor/rrd/"

##
## RTT
##

rrd_file = "rtt.rrd"

akamai,limelight,edgecast,fastly,cloudflare,instartlogic,cdnetworks = nil
res = `fping -q -c 5 www.akamai.com www.edgecast.com www.limelight.com www.fastly.com www.cloudflare.com www.instartlogic.com www.cdnetworks.com 2>&1 | awk '{print $1,$8}' |xargs`.split
log.info "Bulk update: #{res}"

rtt_res = Hash[*res]

rtt_res.each do |key, value|
  avg_rtt = value.split('/')[1]
  case key
    when /akamai/
      akamai = avg_rtt
      log.info "Akamai RTT: #{akamai}"
    when /limelight/
      limelight = avg_rtt
      log.info "Limelight RTT: #{limelight}"
    when /edgecast/
      edgecast = avg_rtt
      log.info "Edgecast RTT: #{edgecast}"
    when /fastly/
      fastly = avg_rtt
      log.info "Fastly RTT: #{fastly}"
    when /cloudflare/
      cloudflare = avg_rtt
      log.info "Cloudflare RTT: #{cloudflare}"
    when /instartlogic/
      instartlogic = avg_rtt
      log.info "Instartlogic RTT: #{instartlogic}"
    when /cdnetworks/
      cdnetworks = avg_rtt
      log.info "CDNetworks RTT: #{cdnetworks}"
  end
end

`rrdtool update #{rrd_dir}#{rrd_file} N:#{akamai}:#{limelight}:#{edgecast}:#{fastly}:#{cloudflare}:#{instartlogic}:#{cdnetworks}`

if $?.success?
  log.info "RTT rrd udpated"
else
  log.info "[error] updating rrd file failed!!"
end

##
## CURL breakdown
##

test_obj = Hash[
"akamai" => "https://developer.akamai.com/img/akamai-logo.svg",
"limelight" => "https://control.llnw.com/portal/branding/llnw/images/company_logo.png",
"edgecast" => "https://my.edgecast.com/_images/cultures/blank.png",
"fastly" => "https://app.fastly.com/images/fastly_logo_red.png",
"cloudflare" => "https://www.cloudflare.com/media/images/core/cloudflare-logo.png",
"instartlogic" => "https://instartlogic.com/_media/logos/instartlogic.svg",
"cdnetworks" => "https://control.cdnetworks.com/op_media/cdnetworks_standalone/en-us/core/images/logo.png"
]


def cmd(url)
	fqdn = url.split('/')[2]
	curl = %Q{ curl -I -s -o /dev/null -H "Host: #{fqdn}" -H "Accept-Encoding: gzip, deflate" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2)" -w "DNSLookup: %{time_namelookup} Handshake: %{time_connect} TLSHandshake: %{time_appconnect} TTFB: %{time_starttransfer} Total: %{time_total}" #{url} | cut -d ' ' -f2,4,6,8,10 }
end

akamai,limelight,edgecast,fastly,cloudflare,instartlogic,cdnetworks = [], [], [], [], [], [], [], []

test_obj.each do |key,test_url|
	value = Hash.new
	test_cmd = cmd(test_url)
	res = `#{test_cmd}`.split
	dns_lookup = res[0].to_f * 1000
	tcp_handshake = res[1].to_f * 1000
	tls_handshake = res[2].to_f * 1000
	ttfb = res[3].to_f
	total = res[4].to_f * 1000

	tls_handshake = (tls_handshake - tcp_handshake) / 1000
	tcp_handshake = (tcp_handshake - dns_lookup) / 1000
	dns_lookup /= 1000

	case key
		when /akamai/
			akamai << dns_lookup << tcp_handshake << tls_handshake << ttfb
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
		when /limelight/
			limelight.push(dns_lookup, tcp_handshake, tls_handshake, ttfb)
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
		when /edgecast/
			edgecast.push(dns_lookup, tcp_handshake, tls_handshake, ttfb)
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
		when /fastly/
			fastly.push(dns_lookup, tcp_handshake, tls_handshake, ttfb)
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
		when /cloudflare/
			cloudflare.push(dns_lookup, tcp_handshake, tls_handshake, ttfb)
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
		when /instartlogic/
			instartlogic.push(dns_lookup, tcp_handshake, tls_handshake, ttfb)
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
		when /cdnetworks/
			cdnetworks.push(dns_lookup, tcp_handshake, tls_handshake, ttfb)
			log.info "#{key} => DNS_Lookup: #{dns_lookup} TCP_Handshake: #{tcp_handshake} TLS_Handshake: #{tls_handshake} TTFB: #{ttfb}"
	end

end


`rrdtool update #{rrd_dir}dns_lookup.rrd N:#{akamai[0]}:#{limelight[0]}:#{edgecast[0]}:#{fastly[0]}:#{cloudflare[0]}:#{instartlogic[0]}:#{cdnetworks[0]}`
`rrdtool update #{rrd_dir}tcp_handshake.rrd N:#{akamai[1]}:#{limelight[1]}:#{edgecast[1]}:#{fastly[1]}:#{cloudflare[1]}:#{instartlogic[1]}:#{cdnetworks[1]}`
`rrdtool update #{rrd_dir}tls_handshake.rrd N:#{akamai[2]}:#{limelight[2]}:#{edgecast[2]}:#{fastly[2]}:#{cloudflare[2]}:#{instartlogic[2]}:#{cdnetworks[2]}`
`rrdtool update #{rrd_dir}first_byte.rrd N:#{akamai[3]}:#{limelight[3]}:#{edgecast[3]}:#{fastly[3]}:#{cloudflare[3]}:#{instartlogic[3]}:#{cdnetworks[3]}`

=begin
if $?.success?
	log.info "RTT rrd udpated"
else
	log.info "[error] updating rrd file failed!!"
end
=end
