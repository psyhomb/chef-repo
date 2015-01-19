provides "iptables"
iptables Mash.new

`iptables -S`.each_line.with_index do |line,i|
  iptables[i] = line
end
