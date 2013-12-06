#!/usr/bin/env ruby
#
# Script to poll Nessus and get lots of results

require 'rest_client'
require 'highline/import'
require 'logger'
require 'open-uri'
require 'json'


def listvulns
  response = RestClient.post "#{@nessus}/report2/vulnerabilities", { :token => @token, :seq => '2812', :report => @uuid, :json => 1  }
  p response.to_s
end

def listScans
  response = RestClient.post "#{@nessus}/scan/list", { :token => @token, :seq => '2812', :report => @uuid, :json => 1  }
  p response.to_s
end

def queryPlugin
  pluginid = 10302
  sev = 0
  response = RestClient.post "#{@nessus}/report2/hosts/plugin", { :token => @token, :seq => '2812', :report => @uuid, :json => 1, :severity => sev, :plugin_id => pluginid}
  doc = JSON.parse(response.to_s)
  #puts JSON.pretty_generate(doc) 
  print "List of hosts vulnerable to plugin #{pluginid} of severity #{sev}\n"
  doc['reply']['contents']['hostlist']['host'].each do |h|
    # Iterate through the elements
    if( h[0] == "hostname" ) 
      print "Hostname: #{h[1]}\n"
    end
  end
end


def hostList
fQuality = "match"
fValue = "10302"
fFilter = "pluginid"
fType = "and"
  response = RestClient.post "#{@nessus}/report2/hosts", { :token => @token, :seq => '2812', :report => @uuid, :json => 1 }

  doc = JSON.parse(response.to_s)
  #puts JSON.pretty_generate(doc) 

  doc['reply']['contents']['hostlist']['host'].each do |h|
    # Iterate through the elements
    if( h[0] == "hostname" ) 
      print "Hostname: #{h[1]}\n"
    end
  end
end




log = Logger.new(STDOUT)
RestClient.log = log
@nessus = 'https://172.31.2.145:8834'
#response = RestClient.get 'https://kali:8834/html5.html#/', :params => { :foo => 'bar', :baz => 'qux' }

password = ask("Password:  ") { |q| q.echo = false }

# Log In to Nessus
response = RestClient.post "#{@nessus}/login", :login => 'root', :seq => '2811', :password => password
# Parse out the 'token' cookie
@token = nil
response.cookies.each do |c|
  if( c[0] == 'token' ) # Grab the cookie
    @token = c[1]
  end
end

#listScans       # Uncomment this line to list all scans in the nessus database
# URI of the scan we care about 
@uuid = URI::encode("b3a1680b-f701-ba73-7479-7a74c05534b05118cdcf245c6ce5")

queryPlugin
exit
