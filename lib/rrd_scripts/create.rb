#!/usr/bin/env ruby

require 'logger'
log = Logger.new('/home/dchoi/projects/dch.io/logs/create.log')
oldtime = 1390208963	# Mon Jan 20 09:09:23 UTC 2014

rrd_dir = "/home/dchoi/projects/dch.io/public/vendor/rrd/"

rtt_rrd_file = "rtt.rrd"
dns_lookup_rrd_file = "dns_lookup.rrd"
tcp_handshake_rrd_file = "tcp_handshake.rrd"
tls_handshake_rrd_file = "tls_handshake.rrd"

archives = "RRA:AVERAGE:0.5:1:300 RRA:AVERAGE:0.5:6:1600 RRA:AVERAGE:0.5:288:800"

#%w/ rtt.rrd dns_lookup.rrd tcp_handshake.rrd tls_handshake.rrd first_byte.rrd /.each do |rrd_file|
	#`rrdtool create #{rrd_dir}#{rrd_file} --start #{oldtime}\
	`rrdtool create #{rrd_dir}#{rrd_file} \
	DS:akamai:GAUGE:600:0:U  \
	DS:limelight:GAUGE:600:0:U  \
	DS:edgecast:GAUGE:600:0:U  \
	DS:fastly:GAUGE:600:0:U \
	DS:cloudflare:GAUGE:600:0:U \
	DS:instartlogic:GAUGE:600:0:U \
	DS:cdnetworks:GAUGE:600:0:U \
	#{archives}`
	if $?.success?
			log.info "#{rrd_file} rrd created"
	else
			log.info "[error] creating #{rrd_file} rrd file failed!!"
	end
end
