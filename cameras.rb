#!/usr/bin/env ruby

require 'mechanize'


a = Mechanize.new
a.read_timeout = 2
a.open_timeout = 2
prefix = "192.168.0"

(6..255).each do |i|
	success = 0
	url = "http://#{prefix}.#{i}/user/cgi-bin/view_S_u.thtml" 
	begin
		page = a.get( url )
		print "**** SUCCESS for #{url}\n"
		success = 1
	rescue
		
	end
	if( success == 0 )
		url = "http://#{prefix}.#{i}/view/viewer_index.shtml"
		begin
			page = a.get( url )
			print "**** SUCCESS for #{url}\n"
			success = 1
		rescue
		
		end
	end
	if( success == 0 )
		print "FAILURE for #{prefix}.#{i}\n"
	end
end

