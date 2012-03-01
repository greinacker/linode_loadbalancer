#!/usr/bin/env ruby

require 'linode'

if ARGV.count != 2 || !["accept","reject"].include?(ARGV[1])
  puts "usage: loadbalancer {host_label} {accept|reject}"
  exit
end

cmd_label = ARGV[0]
cmd_action = ARGV[1]

l = Linode.new(:api_key => "LINODE API KEY HERE")

nb_list = l.nodebalancer.list
nb = nb_list.first
puts "Found NodeBalancer #{nb.label} (#{nb.nodebalancerid})"

monitor_nodes = Array.new

config_list = l.nodebalancer.config.list(:NodeBalancerID => nb.nodebalancerid)
config_list.each do |conf|
  nodes = l.nodebalancer.node.list(:ConfigID => conf.configid)
  nodes.each do |node|
    if node.label == cmd_label
      puts "found node on port #{conf.port}, changing status to #{cmd_action}"
      l.nodebalancer.node.update(:NodeID => node.nodeid, :Mode => cmd_action)
      puts "  status changed to #{cmd_action}"
      monitor_nodes << {:config => conf, :node_id => node.nodeid}
    end
  end
end

print "Waiting for propagation..."

new_status = cmd_action == "reject" ? "DOWN" : "UP"
completed = false
while !completed do
  completed = true
  monitor_nodes.each do |mn|
    nodes = l.nodebalancer.node.list(:ConfigID => mn[:config].configid)
    node = nodes.find {|n| n.nodeid == mn[:node_id]}
    print "."
    completed = false if node.status != new_status
  end
  sleep(2) if !completed
end

puts "\nDone."
