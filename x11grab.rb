#!/usr/bin/env ruby
# Creates a paste-able block for you to screendump (and then view) a remote X11 display

if( ARGV.length != 2 )
  print "Usage: x11grab.rb <ip> <display> (ex: x11grab.rb 192.168.1.1 0)\n"
  exit
end

ip = ARGV[0].to_s.chomp
display = ARGV[1].to_s.chomp

d = `date +%F-%H%M%S`.chomp # Get our date in the YYYY-MM-DD-HHMMSS format
dir = "/opt/Foreground/Ops"

system( "mkdir -p #{dir}" ) # Ensure the directory exists

print "xwd -root -screen -silent -display #{ip}:#{display} > #{dir}/screenshot-#{ip}-#{d}.xwd\n" 
print "convert #{dir}/screenshot-#{ip}-#{d}.xwd #{dir}/screenshot-#{ip}-#{d}.png\n" 
print "dillo #{dir}/screenshot-#{ip}-#{d}.png\n"

