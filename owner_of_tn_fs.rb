#!/usr/local/bin/ruby

require 'net/ssh'

$arg = ARGV[0]

def usage
  print("\n\nUsage: ./owner_of_tn.rb <telephone number>\n\n")
  exit
end

usage if $arg.nil?

def display
  puts "\n - Checking the feature servers now.\n\n"
end

def login_and_query(command,forward_check)

  @username = 'agxxxxxx'
  @password = 'LXXXXXXXXXX'

  $feature_servers, $results, $node = [], [], []
  $feature_servers.push('fsa.xxx.xxx','cm-fsa.xxx.xxx','pl-fsa.xxx.xxx')

  $feature_servers.each do |i|
    @hostname = i
    begin
      Net::SSH.start(@hostname, @username, :password => @password ) do |ssh|
        command_res = ssh.exec!(command)
        $node.push    ssh.exec!("uname -n")
        command_res = command_res.scan(Regexp.union(/[0-9]+.ext:/,/[0-9]+.num:/,/[0-9]+.sip:/)).uniq.to_s unless command_res.nil?
        command_res = command_res.scan(Regexp.union(/[0-9]+.ext/,/[0-9]+.num/,/[0-9]+.sip/))              unless command_res.nil?
        $results.push command_res unless command_res.nil?
      end
    rescue => e
      puts "Error: #{e}"
    end
  end

  $results.each do |line|
    $account_number = line.first.to_s.gsub(/.(num|ext|sip)/,"")
  end

  #$nodeName.each do |node|
  $node.each do |n|
    if !$account_number.nil?
    puts "\n -> Found number #{$arg}"
      puts " -> For account:  #{$account_number.to_s.gsub(/[\[\"\]]/,'')}"
      puts " -> On the #{n.gsub(/\n+/,'')} feature server."
    else
      puts " => #{$arg} not found on the #{$node.last.gsub(/\n+/,'')} feature server."
    end
  end

end

display
login_and_query("egrep #{$arg} /etc/asterisk/customer/*",false)
#login_and_query("asterisk -rx 'database show CFV' | egrep #{$arg}",true)
