#!/usr/local/bin/ruby

require 'net/ssh'

$arg = ARGV[0]

def usage
  print("\n\nUsage: ./owner_of_tn.rb <telephone number>\n\n")
  exit
end

usage if $arg.nil?

def login_and_query(number)

  @username = 'agxxxxxx'
  @password = 'LXXXxxxxx'

  $feature_servers, $results, $ext_file, $nodeName, $node = [], [], [], [], []
  $feature_servers.push('fsa.xxx.xxx','cm-fsa.xxx.xxx','pl-fsa.xxx.xxx')

  $feature_servers.each do |i|
    @hostname = i
    begin
      Net::SSH.start(@hostname, @username, :password => @password ) do |ssh|
        $node.push ssh.exec!("uname -n")
        numberGrep = ssh.exec!("egrep #{number} /etc/asterisk/customer/*")
        $nodeName.push ssh.exec!("uname -n") if !numberGrep.nil?
        file = numberGrep.scan(/[0-9]+.num:/).uniq.to_s.scan(/[0-9]+\.num/) unless numberGrep.nil?
        $results.push numberGrep unless numberGrep.nil?
        puts " => #{$arg} not found on the #{$node.last.gsub(/\n+/,'')} feature server." if $nodeName.empty?
      end
    rescue => e
      puts "Error: #{e}"
    end
  end

  $results.each do |line|
    if line =~ /#{$arg}/
      $ext_file.push line.scan(/[0-9]+.num:/).uniq.to_s.scan(/[0-9]+\.num/)
      $account_number = line.scan(/[0-9]+.num:/).uniq.to_s.scan(/[0-9]+/)
    end
  end

  $nodeName.each do |node|
    puts "\n -> Found number #{$arg}"
    puts " -> For account:  #{$account_number.to_s.gsub(/[\[\"\]]/,'')}"
    puts " -> On the #{node.gsub(/\n+/,'')} feature server."
  end

end

login_and_query($arg)
