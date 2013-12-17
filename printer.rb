#!/usr/bin/env ruby

require 'mechanize'

ip = ARGV[0].to_s.chomp
print "Connecting to http://#{ip}\n"


# HP LaserJet M4345 MFP Series
# http://#{ip}/hp/device/this.LCDispatcher?nav=hp.Addressing
# <input name="password" type="password"
agent = Mechanize.new

agent.get( "http://#{ip}/hp/device/this.LCDispatcher?nav=hp.Addressing" ) do |page|

  if( agent.page.forms[0]["password"] =~ /^\s*$/i ) # Blank
    # Blank
  else
    print "Password field: #{agent.page.forms[0]["password"]}\n"
  end

end
