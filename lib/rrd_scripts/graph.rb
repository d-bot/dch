#!/usr/bin/env ruby

require 'logger'
log = Logger.new('/home/dchoi/projects/dch.io/logs/graph.log')

rrd_img_dir = "/home/dchoi/projects/dch.io/public/vendor/imgs/rrd/"
rrd_dir = "/home/dchoi/projects/dch.io/public/vendor/rrd/"

period = %w/ 1year 1month 1week 1day 12hour /
graph_size = "-w 600 -h 230"

# plus operation ------> #CDEF:total=fastly,edgecast,cdnetworks,+,+ \
# y axis scale limit -------> #--upper-limit 100 --rigid \
#	AREA:total#00cc00:"total" \
# http://oss.oetiker.ch/rrdtool-trac/wiki/OutlinedAreaGraph
# RED     #EA644A #CC3118
# ORANGE  #EC9D48 #CC7016
# YELLOW  #ECD748 #C9B215
# GREEN   #54EC48 #24BC14		new: ADFF2F
# BLUE    #48C4EC #1598C3		new: 48D1CC
# PINK    #DE48EC #B415C7
# PURPLE  #7648EC #4D18E4
#

rrd_file = "rtt.rrd"
rrd_img_file = "rtt"

period.each do |period|
  defaultopts = "--end now --start end-#{period} --lower-limit 0 --lazy --slope-mode #{graph_size} --font TITLE:8:Courier --border 1"
	# CANVAS = graph(grid) background
	# BACK = image background

  colors = "--color CANVAS#FFFFFF --color BACK#FFFF"

  `rrdtool graph #{rrd_img_dir}#{rrd_img_file}-#{period}.png #{defaultopts} #{colors} \
  --title "CDN RTT (#{period})" \
  DEF:akamai=#{rrd_dir}#{rrd_file}:akamai:AVERAGE \
  DEF:limelight=#{rrd_dir}#{rrd_file}:limelight:AVERAGE \
  DEF:edgecast=#{rrd_dir}#{rrd_file}:edgecast:AVERAGE \
  DEF:fastly=#{rrd_dir}#{rrd_file}:fastly:AVERAGE \
  DEF:cloudflare=#{rrd_dir}#{rrd_file}:cloudflare:AVERAGE \
  DEF:instartlogic=#{rrd_dir}#{rrd_file}:instartlogic:AVERAGE \
  DEF:cdnetworks=#{rrd_dir}#{rrd_file}:cdnetworks:AVERAGE \
  LINE1:akamai#F29D00:"Akamai" \
  LINE1:limelight#EC944F:"Limelight" \
  LINE1:edgecast#A01C4E:"Edgecast" \
  LINE1:fastly#48D1CC:"Fastly" \
  LINE1:cloudflare#8000C9:"Cloudflare" \
  LINE1:instartlogic#FF70FF:"Instartlogic" \
  LINE1:cdnetworks#ADFF2F:"Cdnetworks"`

  if $?.success?
    log.info "created RTT graphs"
  else
    log.info "[error] creating png file failed!!"
  end

end

rrd_files = %w/ dns_lookup.rrd tcp_handshake.rrd tls_handshake.rrd first_byte.rrd /

period.each do |period|
	defaultopts = "--end now --start end-#{period} --lower-limit 0 --lazy --slope-mode #{graph_size} --font TITLE:8:Calibri --border 1"
  colors = "--color CANVAS#FFFFFF --color BACK#FFFF"

	rrd_files.each do |rrd_file|
		tmp = rrd_file.gsub('.rrd', '').gsub('_', ' ').split
		title = tmp[0].capitalize + " " + tmp[1].capitalize
		rrd = rrd_file.gsub('.rrd', '')
		`rrdtool graph #{rrd_img_dir}#{rrd}-#{period}.png #{defaultopts} #{colors} \
		--title "#{title} (#{period})" \
		DEF:akamai=#{rrd_dir}#{rrd_file}:akamai:AVERAGE \
		DEF:limelight=#{rrd_dir}#{rrd_file}:limelight:AVERAGE \
		DEF:edgecast=#{rrd_dir}#{rrd_file}:edgecast:AVERAGE \
		DEF:fastly=#{rrd_dir}#{rrd_file}:fastly:AVERAGE \
		DEF:cloudflare=#{rrd_dir}#{rrd_file}:cloudflare:AVERAGE \
		DEF:instartlogic=#{rrd_dir}#{rrd_file}:instartlogic:AVERAGE \
		DEF:cdnetworks=#{rrd_dir}#{rrd_file}:cdnetworks:AVERAGE \
		CDEF:akamai1=akamai,1000,* \
		CDEF:limelight1=limelight,1000,* \
		CDEF:edgecast1=edgecast,1000,* \
		CDEF:fastly1=fastly,1000,* \
		CDEF:cloudflare1=cloudflare,1000,* \
		CDEF:instartlogic1=instartlogic,1000,* \
		CDEF:cdnetworks1=cdnetworks,1000,* \
		LINE1:akamai1#F29D00:"Akamai" \
		LINE1:limelight1#EC944F:"Limelight" \
		LINE1:edgecast1#A01C4E:"Edgecast" \
		LINE1:fastly1#48D1CC:"Fastly" \
		LINE1:cloudflare1#8000C9:"Cloudflare" \
		LINE1:instartlogic1#FF70FF:"Instartlogic" \
		LINE1:cdnetworks1#ADFF2F:"Cdnetworks"`

		if $?.success?
		  log.info "created #{rrd_file} graphs"
		else
		  log.info "[error] creating #{rrd_file} failed!!"
		end
	end
end

##
## Handshake vs RTT Graphs
##

graph_size = "-w 310 -h 80"
rtt_rrd = "rtt.rrd"
tcp_handshake_rrd = "tcp_handshake.rrd"

period.each do |period|
  defaultopts = "--end now --start end-#{period} --lower-limit 0 --lazy --slope-mode #{graph_size} --font TITLE:8:calibri --border 1"
  colors = "--color CANVAS#FFFFFF --color BACK#FFFF"
  %w/ akamai limelight edgecast fastly cloudflare instartlogic cdnetworks /.each do |cdn|
    rrd_file = cdn + "_handshake_vs_rtt"
    `rrdtool graph #{rrd_img_dir}#{rrd_file}-#{period}.png #{defaultopts} #{colors} \
    --title "#{cdn.capitalize} (#{period})" \
    DEF:#{cdn}_tcp=#{rrd_dir}#{tcp_handshake_rrd}:#{cdn}:AVERAGE \
    DEF:#{cdn}_rtt=#{rrd_dir}#{rtt_rrd}:#{cdn}:AVERAGE \
    CDEF:#{cdn}_tcp1=#{cdn}_tcp,1000,* \
    AREA:#{cdn}_tcp1#00cc00:"TCP Handshake" \
    LINE1:#{cdn}_rtt#0000cc:"RTT"`

		if $?.success?
		  log.info "created #{rrd_file} graphs"
		else
		  log.info "[error] creating #{rrd_file} failed!!"
		end
  end
end


##
## Breakdown Graphs
##

graph_size = "-w 600 -h 230"

period.each do |period|
  defaultopts = "--end now --start end-#{period} --lower-limit 0 --lazy --slope-mode #{graph_size} --font TITLE:8:calibri --border 1"
  colors = "--color CANVAS#FFFFFF --color BACK#FFFF"
  %w/ akamai limelight edgecast fastly cloudflare instartlogic cdnetworks /.each do |cdn|
    `rrdtool graph #{rrd_img_dir}#{cdn}-breakdown-#{period}.png #{defaultopts} #{colors} \
    --title "#{cdn.capitalize} (#{period})" \
    DEF:#{cdn}_dns=#{rrd_dir}dns_lookup.rrd:#{cdn}:AVERAGE \
    DEF:#{cdn}_tcp=#{rrd_dir}tcp_handshake.rrd:#{cdn}:AVERAGE \
    DEF:#{cdn}_tls=#{rrd_dir}tls_handshake.rrd:#{cdn}:AVERAGE \
    DEF:#{cdn}_ttfb=#{rrd_dir}first_byte.rrd:#{cdn}:AVERAGE \
    AREA:#{cdn}_dns#48D1CC:"DNS Lookup" \
    STACK:#{cdn}_tcp#EC944F:"TCP Handshake" \
    STACK:#{cdn}_tls#E51505:"TLS Handshake" \
    STACK:#{cdn}_ttfb#8000C9:"TTFB"`

		if $?.success?
		  log.info "created #{cdn} graphs"
		else
		  log.info "[error] creating #{cdn} failed!!"
		end
  end
end

#   LINE1:#{cdn}_dns#C9B215 \
#   LINE1:#{cdn}_tcp#1598C3 \
#   LINE1:#{cdn}_tls#CC3118 \
#   LINE1:#{cdn}_ttfb#CC7016`
