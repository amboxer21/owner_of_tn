#!/usr/local/bin/ruby
require "/var/asterisk/hosted/current/hpbxgui/config/environment.rb"

@tn = ARGV[0]

@flag, @modes, @fwd_flag, @e911_flag   = "false"
@ucid_flag, @fax_number, @umobile_flag = "false"

if Did.find_by_tn(@tn).nil?
  puts "\n => DID (#{@tn}) was not found!\n\n"
else
  puts "\n -> Found DID #{@tn}"
  puts " -> Tenant name => #{Tenant.find_by(id: Did.find_by_tn(@tn).tenant_id).name}"
  puts " -> Tenant description => #{Tenant.find_by(id: Did.find_by_tn(@tn).tenant_id).description}"
  puts " -> Workgroup => #{Location.find_by(id: Did.find_by_tn(@tn).location_id).name}"
  puts " -> Account number: ##{Account.find_by(tenant_id: Did.find_by_tn(@tn).tenant_id).account_number}"
end

Tenant.all.each do |t|

  t.locations.each do |location|
    next if Mode.find_by(location_id: location.id).nil?
    @mode = Mode.find_by(location_id: location.id)
    @mode.permanent_routes.each do |m|
      if Did.find_by(id: m.did_id).to_s.match(/#{@tn}/)
        puts "\n -> Number was found for tenant(#{user.name}) using MODE(#{@mode.name}). " +
        "Going to DESTINATION(#{ScriptCall.find_by(id: @mode.script_call_id).name}).\n\n"
        @modes = "true"
      end
    end
  end

  t.users.extension_users.each do |ext|
    next if ext.e911_callerid.nil?
    if ext.e911_callerid =~ /#{@tn}/
      puts "\n -> Found e911 number #{ext.e911_callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}"
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n" 
      @e911_flag = "true"
    end

    next if ext.callerid.nil?
    if ext.callerid =~ /#{@tn}/
      puts "\n -> Found CID number #{ext.callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}"
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n" 
      @ucid_flag = "true"
    end

    next if ext.mobile_tn.nil?
    if ext.mobile_tn =~ /#{@tn}/
      puts "\n -> Found mobile number #{ext.mobile_tn}\n"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}."
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n" 
      @umobile_flag = "true"
    end

    next if ext.ami_hash.nil?
    ext.ami_hash.each do |key,val|
      if key =~ /CFAN/ && val =~ /#{@tn}/
        puts "\n\n -> Found forward number #{val}\n -> For user: #{ext.name}" unless ext.nil?
        puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}."
        puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n"
        @fwd_flag = "true"
      end
    end

    next if ext.fax_did_id.nil?
    if Did.find_by(id: ext.fax_did_id).tn.to_s.match(/#{@tn}/) && !Did.find_by(id: ext.fax_did_id).nil?
      puts "\n\n -> Found Email-To-Fax number #{@tn}\n -> For user: #{ext.name}" unless ext.nil?
      puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}."
      puts " -> For workgroup #{Location.find_by(tenant_id: ext.tenant_id).name}.\n\n"
      @fax_number = "true"
    end

    next if ext.callerid.nil?
    if ext.callerid =~ /#{@tn}/
      puts "\n -> Tenant CID (#{ext.callerid}) was found for tenant #{t.name}, user #{ext.name}.\n"
      @flag = "true"
    end

  end
end

puts "\n => User E911 number not found.\n\n"    unless @e911_flag == "true"
@e911_flag = false

puts "\n => User CID number not found.\n\n"     unless @ucid_flag == "true"
@ucid_flag = false

puts "\n => User mobile number not found.\n\n"  unless @umobile_flag == "true"
@umobile_flag = false

puts "\n => User Forward number not found.\n\n" unless @fwd_flag == "true"
@fwd_flag = false

puts "\n => Email-To-Fax number not found.\n\n" unless @fax_number == "true"
@fax_number = false

puts "\n => Tenant CID number not found.\n\n" unless @flag == "true"
@flag = "false"
puts "\n => Mode DID not found.\n\n" unless @modes == "true"
@modes = "false"
