#!/usr/local/bin/ruby
require "/var/asterisk/hosted/current/hpbxgui/config/environment.rb"

@tn  = ARGV[0]

@flag, @modes, @fwd_flag, @e911_flag       = "false"
@ucid_flag, @fax_number, @umobile_flag     = "false"
@active_did, @inactive_did, @override_flag = "false"

Tenant.all.each do |t|

  if t.callerid.match(/#{@tn}/)
    puts " -> Found tenant default callerid number(#{@tn}) for tenant #{t.name}"
  end
  t.inactive_dids.each do |d|
    if d.tn.to_s.match(/#{@tn}/)
      puts " -> Found inactive did(#{d.tn}) for tenant #{t.name}"
      @inactive_did = "true"
    end
  end
  t.active_dids.each do |d|
    if d.tn.to_s.match(/#{@tn}/)
      puts " -> Found active did(#{d.tn}) for tenant #{t.name}"
      @active_did = "true"
    end
  end

  t.locations.each do |location|

    #next if Mode.find_by(location_id: location.id).nil?
    #@mode = Mode.find_by(location_id: location.id)
    @mode = Mode.find_by(location_id: location.id)
    next if @mode.nil?
    @mode.permanent_routes.each do |m|
      if Did.find_by(id: m.did_id).to_s.match(/#{@tn}/)
        puts "\n -> Number was found for tenant(#{t.name}) using MODE(#{@mode.name}). " +
        "Going to DESTINATION(#{ScriptCall.find_by(location_id: location.id).name}).\n\n"
        @modes = "true"
      end
    end

    next if location.active_dids.nil?
    location.active_dids.each do |d|
      if d.to_s.match(/#{@tn}/)
        puts "\n -> Found active DID #{@tn}"
        puts " -> Tenant name => #{t.name}"
        puts " -> Tenant description => #{t.description}"
        puts " -> Workgroup => #{location.name}"
        puts " -> Account number: ##{Account.find_by(tenant_id: t.id).account_number}"
      end
      @active_did = "true"
    end

    next if location.inactive_dids.nil? or location.inactive_dids.empty?
    location.inactive_dids.each do |d|
      if d.tn.to_s.match(/#{@tn}/)
        puts "\n -> Found inactive DID #{@tn}"
        puts " -> Tenant name => #{t.name}"
        puts " -> Tenant description => #{t.description}"
        puts " -> Workgroup => #{location.name}"
        puts " -> Account number: ##{Account.find_by(tenant_id: t.id).account_number}"
      end
      @inactive_did = "true"
    end

  end

  t.users.extension_users.each do |ext|
    next if ext.e911_callerid.nil?
    if ext.e911_callerid.to_s.match(/#{@tn}/)
      puts "\n -> Found e911 number #{ext.e911_callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{ext.account.account_number}"
      puts " -> For workgroup #{ext.location.name}.\n\n" 
      @e911_flag = "true"
    end

    next if ext.callerid.nil?
    if ext.callerid.to_s.match(/#{@tn}/)
      puts "\n -> Found CID number #{ext.callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{ext.account.account_number}"
      puts " -> For workgroup #{ext.location.name}.\n\n" 
      @ucid_flag = "true"
    end

    next if ext.ext_callerid.nil?
    if ext.ext_callerid.to_s.match(/#{@tn}/)
      puts "\n -> Found CID override number #{ext.ext_callerid}"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{ext.account.account_number}"
      puts " -> For workgroup #{ext.location.name}.\n\n"
      @override_flag = "true"
    end

    next if ext.mobile_tn.nil?
    if ext.mobile_tn.to_s.match(/#{@tn}/)
      puts "\n -> Found mobile number #{ext.mobile_tn}\n"
      puts " -> For user #{ext.name}"
      puts " -> For account ##{ext.account.account_number}."
      puts " -> For workgroup #{ext.location.name}.\n\n" 
      @umobile_flag = "true"
    end

    next if ext.ami_hash.nil?
    ext.ami_hash.each do |key,val|
      if key.to_s.match(/CFAN/) && val.to_s.match(/#{@tn}/)
        puts "\n\n -> Found forward number #{val}\n -> For user: #{ext.name}" unless ext.nil?
        puts " -> For account ##{ext.account.account_number}."
        puts " -> For workgroup #{ext.location.name}.\n\n"
        @fwd_flag = "true"
      end
    end

    @fax_did = Did.find_by(id: ext.fax_did_id)
    #next if ext.fax_did_id.nil? || Did.find_by(id: ext.fax_did_id).nil?
    next if ext.fax_did_id.nil? || @fax_did.nil?
    #if Did.find_by(id: ext.fax_did_id).tn.to_s.match(/#{@tn}/) && !Did.find_by(id: ext.fax_did_id).nil?
    if @fax_did.tn.to_s.match(/#{@tn}/) && !@fax_did.nil?
      puts "\n\n -> Found Email-To-Fax number #{@tn}\n -> For user: #{ext.name}" unless ext.nil?
      puts " -> For account ##{ext.account.account_number}."
      puts " -> For workgroup #{ext.location.name}.\n\n"
      @fax_number = "true"
    end

    next if ext.callerid.nil?
    if ext.callerid.to_s.match(/#{@tn}/)
      puts "\n -> User CID (#{ext.callerid}) was found for tenant #{t.name}, user #{ext.name}.\n"
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

puts "\n => Tenant CID number not found.\n\n"   unless @flag == "true"
@flag = "false"

puts "\n => Mode DID not found.\n\n"            unless @modes == "true"
@modes = "false"

puts "\n => Active DID not found.\n\n"          unless @active_did == "true"
@active_did = "false"

puts "\n => Inactive DID not found.\n\n"        unless @inactive_did == "true"
@inactive_did = "false"

puts "\n => Callerid override not found.\n\n"   unless @override_flag == "true"
@override_flag = "false"
