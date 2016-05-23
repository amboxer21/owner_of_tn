#!/usr/local/bin/ruby
require "/var/asterisk/hosted/current/hpbxgui/config/environment.rb"

@tn = ARGV[0]

def set_did_vars
  if !Did.find_by_tn(@tn).nil?
    @loc_id = Did.find_by_tn(@tn).location_id unless loc_id = Did.find_by_tn(@tn).nil?
    @ten_id = Did.find_by_tn(@tn).tenant_id unless ten_id = Did.find_by_tn(@tn).nil?
  end
end

def set_user_vars
  if !User.find_by(mobile_tn: @tn).nil?
    @user = User.find_by(mobile_tn: @tn).name 
    @utn = User.find_by(mobile_tn: @tn).mobile_tn
    @wg = User.find_by(mobile_tn: @tn).location.name
    @location_id = User.find_by(mobile_tn: @tn).location_id
    @cid = User.find_by(mobile_tn: @tn).location.callerid
  end
end

set_did_vars
set_user_vars

if Did.find_by_tn(@tn).nil?
  puts "\n => DID (#{@tn}) was not found!\n"
else
  puts "\n\n -> Telephone number #{@tn} belongs to:\n"
  puts " -> Tenant => #{Tenant.find_by_id(@ten_id).name}"
  puts " -> Workgroup => #{Location.find_by_id(@loc_id).name}"
end
 
if User.find_by(mobile_tn: @tn).nil?
  puts "\n => Mobile number (#{@tn}) was not found.\n"
else
  puts "\n -> Telephone number #{@utn} was found for user #{@user}."
  puts " -> For locationd_id: #{@location_id}."
  puts " -> For workgroup: #{@wg}.\n"
end

if User.find_by(mobile_tn: @tn).nil?
  puts "\n => CID for user not found.\n\n"
else
  return if @cid.nil? || @user.nil?
  puts "\n -> CID (#{@cid}) was found for user #{@user}.\n\n"
end
