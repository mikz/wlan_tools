require 'pathname'

DICT = Pathname.new('dict')

scan = `airport -s`
lines = scan.split("\n")

header = lines.shift.strip.split(' ')

def wpamagickey(bssid, essid)
  dict = DICT.join(essid)
  system('wpamagickey', essid, bssid, dict.to_path.to_s)
end

lines.each do |line|
  essid, bssid, signal, channel, rest = line.strip.split(/\s+/)
  case essid
    when /^WLAN_.{4}$/
      wpamagickey(bssid, essid)
    when /^JAZZTEL_.{4}$/
      wpamagickey(bssid, essid)
  end
end
