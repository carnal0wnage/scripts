#!/usr/bin/env ruby
#
# Script to poll Nessus and get lots of results

require 'rest_client'
require 'highline/import'
require 'logger'

log = Logger.new(STDOUT)
RestClient.log = log
@nessus = 'https://172.31.2.145:8834'
#response = RestClient.get 'https://kali:8834/html5.html#/', :params => { :foo => 'bar', :baz => 'qux' }

password = ask("Password:  ") { |q| q.echo = false }

# Log In to Nessus
response = RestClient.post "#{@nessus}/login", :login => 'root', :seq => '2811', :password => password
#RestClient.post 'http://example.com/resource', :param1 => 'one', :nested => { :param2 => 'two' }

p response.cookies
exit

response = RestClient.get "#{@nessus}"
p response

# response.code
# response.cookies
# response.headers
# response.to_str
#

