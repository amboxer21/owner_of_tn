#!/usr/local/bin/ruby
require "/var/asterisk/hosted/current/hpbxgui/config/environment.rb"

@flag = "true"
@tn   = ARGV[0]

def set_did_vars
  unless Did.find_by_tn(@tn).nil?
    @ten_id     = Did.find_by_tn(@tn).tenant_id 
    @loc_id     = Did.find_by_tn(@tn).location_id 
  end
end

def set_user_vars
  unless User.find_by(mobile_tn: @tn).nil?
    @user        = User.find_by(mobile_tn: @tn).name 
    @utn         = User.find_by(mobile_tn: @tn).mobile_tn
    @location_id = User.find_by(mobile_tn: @tn).location_id
    @cid         = User.find_by(mobile_tn: @tn).location.callerid 
  end
end
 
def set_global_vars
    @ten         = Tenant.find_by_id(@ten_id).name                    unless Tenant.find_by_id(@ten_id).nil?
    @account     = Account.find_by(tenant_id: @ten_id).account_number unless Account.find_by(tenant_id: @ten_id).nil?
    @account_id  = Account.find_by(account_number: @ten_id).id        unless Account.find_by(account_number: @ten_id).nil?
    @wg          = Location.find_by(account_id: @account_id).name     unless Location.find_by(account_id: @account_id).nil?
end

set_did_vars
set_user_vars
set_global_vars

if Did.find_by_tn(@tn).nil?
  puts "\n => DID (#{@tn}) was not found!\n"
else
  puts "\n\n -> Telephone number #{@tn} belongs to:\n"
  puts " -> Tenant => #{@ten}"
  puts " -> Workgroup => #{@wg}"
  puts " -> Account number: #{@account}"
end
 
if User.find_by(mobile_tn: @tn).nil?
  puts "\n => Mobile number (#{@tn}) was not found.\n"
else
  puts "\n -> Telephone number #{@utn} was found for user #{@user}."
  puts " -> For locationd_id: #{@location_id}."
  puts " -> For workgroup: #{@wg}.\n"
end

if User.find_by(mobile_tn: @tn).nil? || @cid.nil?
  puts "\n => CID for user not found.\n"
else
  puts "\n -> CID (#{@cid}) was found for user #{@user}.\n"
end

Tenant.all.each do |user|
  user.users.each do |ext|
    unless ext.e911_callerid.nil?
      if ext.e911_callerid =~ /#{@tn}/
        puts "\n -> Found e911 number #{ext.e911_callerid}"
        puts " -> For user #{ext.name}"
        puts " -> For account ##{Account.find_by(tenant_id: ext.tenant_id).account_number}.\n\n"
        @flag = "true"
      else
        @flag = "false"
      end
    end
  end
end

puts "\n => E911 number not found.\n\n" unless @flag == "true"
