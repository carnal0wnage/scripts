#!/usr/bin/env ruby

# Operation @version
# Author: Joe Barrett
# 
# Code that will handle the operational tasks, setting up environment, etc.
# 

require "trollop"
require "awesome_print"

@version = "0.1a"
@data = "/DATA"
@optag = ".9B3C8720-5C21-416E-B4E9-751C423496FA" # A GUID just for you
@inop = nil # Are we in an op or not?
@opstart = nil

# This is the most basic environment preparation
def validateEnvironment
######### Ensure that the root data directory exists
  if( File.directory?( @data ) ) # We exist
  else
    begin
      Directory.mkdir(@data)
    rescue
      print "Couldn't create #{@data} automatically. Please create it yourself and re-run the script.\n"
      exit
    end
  end
######### See if we're within an op at the moment
  if( File.exists?( "#{@data}/#{@optag}" ) )
    @inop = true
    File.open( "#{@data}/#{@optag}" ).read.each_line do |line|
      opstart = line.chomp!
      print "Op Start is #{opstart}\n"
    end
  else
    @inop = false
  end
#  print "Are we in an op? #{@inop}\n"
end


### Start an operation
def startOp
  print "Starting operation #{@handle} at time #{Time.now.to_i}\n"

end


### Finish an operation
def finishOp

end









print "Operation Manager v#{@version}\n\n"
validateEnvironment

@opts = Trollop::options do
  opt :in, "Begin Operation", :default => false         # Flag --in, default false
  opt :out, "End Operation", :default => false          # Flag --out, default false
  opt :handle, "Operation Handle", :type => :string     # Name for the op
end

if( @opts[:in] == false && @opts[:out] == false )
  print "You need to either begin or end an operation.\n"
  print "\tIndecision is not a valuable trait.\n"
  exit
elsif( @opts[:in] && @inop == true )
  print "You're trying to start an op, but #{@data}/#{@optag} already exists.\n"
  print "\tIf you really know what you're doing, you can override this.\n" # This is a lie.
  exit
elsif( @opts[:out] && @inop == false )
  print "You're trying to exit an op, but #{@data}/#{@optag} doesn't exist.\n"
  print "\tDid you ever start the op properly or are you just confused?\n"
  exit
elsif( @opts[:in] && @opts[:handle] == nil )
  print "You're trying to start an op but haven't given it a handle. Please do so.\n"
  print "\tRerun with --help if you're confused.\n"
  exit
elsif( @opts[:in] )
  @handle = @opts[:handle].upcase
  startOp
elsif( @opts[:out] )
  finishOp
else
  print "What combination of options got you here?\n"
  print "\tTime to code up some bug fixes\n"
  ap @opts
  exit
end




