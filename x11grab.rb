#!/usr/bin/env ruby

ip = ARGV[0].to_s.chomp
display = ARGV[1].to_s.chomp

d = `date +%F:%H-%M`.chomp
dir = "~/Foreground/Ops"

print "xwd -root -screen -silent -display #{ip}:#{display} > #{dir}/screenshot-#{ip}-#{d}.xwd" 
system( "xwd -root -screen -silent -display #{dir}/#{ip}:#{display} > #{dir}/screenshot-#{ip}-#{d}.xwd" )
print "convert #{dir}/screenshot-#{ip}-#{d}.xwd #{dir}/screenshot-#{ip}-#{d}.png" 
system( "convert #{dir}/screenshot-#{ip}-#{d}.xwd #{dir}/screenshot-#{ip}-#{d}.png" )
print "dillo #{dir}/screenshot-#{ip}-#{d}.png"
system( "dillo #{dir}/screenshot-#{ip}-#{d}.png")
