#!/usr/bin/env ruby

require 'socket'

$remoteHost = "www.vulpinellc.com"        # Remote IP we're forwarding traffic to - PAD server
$remotePort = "80"        # Pad Server Port
$localHost = "127.0.0.1"
$localPort = "8443"

puts "Proxy for #{$remoteHost}:#{$remotePort}\n"

$blockSize = 1024

server = TCPServer.open( $localHost, $localPort )

port = server.addr[1]
addrs = server.addr[2..-1].uniq
print "** Listening on #{addrs.collect{|a|"#{a}:#{port}"}.join(' ')}"

# Abort on exceptions
Thread.abort_on_exception = true

# have a thread to process Control-C events?
Thread.new { loop { sleep 1 } }

def connThread( local )
  port, name = local.peeraddr[1..2]
  puts "** Recv from #{name}:#{port}"
  
  # Open connection to remote server
  remote = TCPSocket.new($remoteHost, $remotePort)
  
  # Start reading from both ends
  loop do
    ready = select( [local,remote], nil, nil )
    if ready[0].include? local
      # Local -> Remote
      data = local.recv($blockSize)
      if data.empty?
        puts "Local end closed connection"
        break
      end
      remote.write(data)
    end
    if ready[0].include? remote
      # Remote -> local
      data = remote.recv($blockSize)
      if data.empty?
        puts "remote end closed connection"
        break
      end
      local.write(data)
    end
  end # End loop

  local.close
  remote.close
  
  puts "** Done with #{name}:#{port}\n"
end # def connThread

loop do
  # Whenever server.accept returns a new connection, start a handler thread
  Thread.start(server.accept) { |local| connThread(local) }
end



