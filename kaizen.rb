#!/usr/bin/env ruby

require 'socket'


def clockGuess ( bottom, top )
	guess = ((( top.to_f - bottom.to_f) / 2.00 ).round(2) + bottom.to_f).round(2)
	print "** Searching from #{bottom} <-> #{top}: #{guess}\n"
	@t.write( "%.2f\n" % guess )
	@t.flush
	data = ""
	while buf = ( @t.readpartial(1024) rescue nil )
		(data ||= "" ) << buf 

		print "d: #{data}\n"
		if( data =~ /low|south|more|under|cold/i ) # We're low, pick the high range
#			print "** We're low, now guessing #{guess} <-> #{top}\n"
			clockGuess( "%.2f" % guess.to_f.round(2), "%.2f" % top.to_f.round(2) )
		elsif( data =~ /high|north|less|hot|steep|overguessed/i ) # We're high, pick the low range
#			print "** We're high, now guessing #{bottom} <-> #{guess}\n"
			clockGuess( "%.2f" % bottom.to_f.round(2), "%.2f" % guess.to_f.round(2) )
		else
#				clockGuess( bottom, top )
		end # else
	end # while loop

	print "#{data}\n"
end

@t = TCPSocket.new( "scripting.kaizen-ctf.com", 15808 )

# Stage one - we're guessing 1500, if we're wrong, relaunch
@t.puts "1500\n"

while buf = ( @t.readpartial(1024) rescue nil )	
	( data ||= "" ) << buf
	if( data =~ /you win/i )
		print "Data: #{data}\n"
		@t.puts " "
		while buf = ( @t.readpartial(1024) rescue nil )
			( data ||= "" ) << buf
			print "#{data}\n"
			clockGuess( 0, 10000 )
		end
	elsif( data =~ /contestant ([1-4]) wins/i )
		print "No win: #{$1} got it. \n"
	end
end

exit



