#!/usr/bin/env ruby

ip = ARGV[0].to_s.chomp
display = ARGV[1].to_s.chomp

print "xwd -root -screen -silent -display #{ip}:#{display} > screenshot-#{ip}.xwd" 
system( "xwd -root -screen -silent -display #{ip}:#{display} > screenshot-#{ip}.xwd" )
print "convert screenshot-#{ip}.xwd screenshot-#{ip}.png" 
system( "convert screenshot-#{ip}.xwd screenshot-#{ip}.png" )
print "dillo screenshot-#{ip}.png"
system( "dillo screenshot-#{ip}.png")
