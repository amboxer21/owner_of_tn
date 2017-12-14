#!/usr/local/bin/ruby

require 'net/ssh'

def usage
  print("\n\nUsage: ./owner_of_tn.rb <telephone number>\n\n")
  exit
end

usage if ARGV[0].nil?

def display
  puts "\n ** Checking the feature servers now **\n\n"
end

def login_and_query(number)

  @username = 'agxxxxxx'
  @password = 'LXXX XXXX X'

  @ngrep = {}
  @feature_servers = ['fxx.xxxxxxxx.com','cm-xxx.xxxxxxxx.com','pl-xxx.xxxxxxxx.com']

  @feature_servers.each do |s|
    begin
      Net::SSH.start(s, @username, :password => @password ) do |ssh|
        @ngrep[ssh.exec!("uname -n")] = ssh.exec!("egrep #{number} /etc/asterisk/customer/*")
          .scan(/\d+\.\w{3}/).uniq
          .to_s.scan(/\d+/).uniq
      end
    rescue => e
      puts "Error: #{e}"
    end
  end

  @ngrep.each do |key,val|
    server = key.upcase.gsub(/\n/,'')
    val.empty? ?
      (puts " => #{number} not found on the [ #{server} ] feature server") :
      (puts " -> Found #{number} on the [ #{server} ] feature sever for account(s) #{val}")
  end

end

display
login_and_query(ARGV[0])
