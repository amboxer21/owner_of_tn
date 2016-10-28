#!/usr/local/bin/ruby
require "/var/asterisk/hosted/current/hpbxgui/config/environment.rb"

@flag         = "true"
@fwd_flag     = "true"
@e911_flag    = "true"
@ucid_flag    = "true"
@umobile_flag = "true"

@tn           = ARGV[0]

if Did.find_by_tn(@tn).nil?
  puts "\n => DID (#{@tn}) was not found!\n"
else
  puts "\n -> Found telephone number #{@tn}"
  puts " -> Tenant name => #{Tenant.find_by(id: Did.find_by_tn(@tn).tenant_id).name}"
  puts " -> Tenant description => #{Tenant.find_by(id: Did.find_by_tn(@tn).tenant_id).description}"
  puts " -> Workgroup => #{Location.find_by(id: Did.find_by_tn(@tn).location_id).name}"
  puts " -> Account number: #{Account.find_by(tenant_id: Did.find_by_tn(@tn).tenant_id).account_number}"
end
 
User.all.each do |ext|
  next if ext.e911_callerid.nil?
    if ext.e911_callerid =~ /#{@tn}/
      puts "\n -> Found e911 number #{ext.e911_callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}"
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n" 
      @e911_flag = "true"
    else
      @e911_flag = "false"
    end

  next if ext.callerid.nil?
    if ext.callerid =~ /#{@tn}/
      puts "\n -> Found CID number #{ext.callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}"
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n" 
      @ucid_flag = "true"
    else
      @ucid_flag = "false"
    end

  next if ext.mobile_tn.nil?
    if ext.mobile_tn =~ /#{@tn}/
      puts "\n -> Found mobile number #{ext.mobile_tn}\n"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}."
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n" 
      @umobile_flag = "true"
    else
      @umobile_flag = "false"
    end

  next if ext.ami_hash.nil?
  ext.ami_hash.each do |key,val|
    if key =~ /CFAN/ && val =~ /#{@tn}/
      puts "\n -> Found forward number #{val}\n -> For user: #{ext.name}" unless ext.nil?
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}."
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n"
      @fwd_flag = "true"
    else
      @fwd_flag = "false"
    end
  end

end

puts "\n => User E911 number not found.\n\n" unless @e911_flag == "true"
@e911_flag = false

puts "\n => User CID number not found.\n\n" unless @ucid_flag == "true"
@ucid_flag = false

puts "\n => User mobile number not found.\n\n" unless @umobile_flag == "true"
@umobile_flag = false

puts "\n => User Forward number not found.\n\n" unless @fwd_flag == "true"
@fwd_flag = false

Tenant.all.each do |user|
  if user.callerid =~ /#{@tn}/
    @flag = "true"
    puts "\n -> Tenant CID (#{user.callerid}) was found for tenant #{user.name}.\n"
  else
    @flag = "false"
  end
end

puts "\n => Tenant CID number not found.\n\n" unless @flag == "true"
