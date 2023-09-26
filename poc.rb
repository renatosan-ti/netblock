#!/usr/bin/ruby

require 'socket'

host = 'whois.pwhois.org'
port = 43

msg = "begin\ntype=jsonp 45.162.224.12\ntype=jsonp registry source-as=268533\ntype=jsonp routeview org-name=rionet tec\nend"

s = TCPSocket.new host, port

s.write msg + "\n"
res = s.read
puts res

s.close
