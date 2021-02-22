require "apple_certs_info"
require "apple_certs_cleaner/version"

module AppleCertsCleaner

  # Remove duplicate Certificate files
  # note: remove first data
  def self.remove_duplicate_certificate
    list = []

    dist_list = AppleCertsInfo.certificate_distribution_list
    develop_list = AppleCertsInfo.certificate_development_list
    list.concat(dist_list) unless dist_list.nil?
    list.concat(develop_list) unless develop_list.nil?

    duplicate_cname = list.group_by{ |e| e[:cname] }.select { |k, v| v.size > 1 }.map(&:first)
    duplicate_cname.each do |cname|
      delete_first_match_keychain(name: cname)
    end
  end

  # Remove expired Certificate files
  def self.remove_expired_certificate
    list = []

    dist_list = AppleCertsInfo.certificate_distribution_list
    develop_list = AppleCertsInfo.certificate_development_list
    list.concat(dist_list) unless dist_list.nil?
    list.concat(develop_list) unless develop_list.nil?

    list.each do |certificate|
      puts certificate

      if certificate[:limit_days].to_i < 0
        puts "Delete Certificate file: #{certificate[:cname]}（expired: #{certificate[:limit_days]}）"
        delete_first_match_keychain(name: certificate[:cname])
      end
    end
  end

  # Remove expired Provisioning Profile
  def self.remove_expired_provisioning_profile
    list = AppleCertsInfo.provisioning_profile_list

    list.each do |pp_file|
      next if pp_file[:file_path].nil?

      if pp_file[:limit_days].to_i < 0
        puts "Delete Provisioning Profile: #{pp_file[:app_id_name]}（expired: #{pp_file[:limit_days]}）"
        File.delete(pp_file[:file_path])
      end
    end
  end

  # Remove revoked Certificate files
  def self.remove_invalid_certificate
    result = `security find-identity  -v -p codesigning`
    invalid_cert_sha1 = result.scan(/[0-9]+\) ([a-zA-Z0-9]+) \".*\" .*CSSMERR_TP_CERT_REVOKED.*/)

    invalid_cert_sha1.each do |sha1|
      delete_keychain_for(sha1: sha1.first)
    end
  end

  private
  # delete keychain using sha1
  def self.delete_keychain_for(sha1:)
    puts "Delete Certificate file: SHA-1 #{sha1}"
    result = `security delete-certificate -Z #{sha1}`
  end

  # delete keychain using name
  def self.delete_first_match_keychain(name:)
    result = `security find-certificate -a -c "#{name}" -Z`
    sha_match = result.match(/SHA-1 hash: (.*)/)
    keychain_path = result.match(/keychain: (.*)/)
    raise "not exits sha-1" if sha_match.nil?
    raise "not exits keychain_path" if keychain_path.nil?
    sha1 = sha_match[1]
    puts "Delete Certificate file: #{name} / SHA-1: #{sha1}"

    result = `security delete-certificate -Z #{sha1} #{keychain_path[1]}`
  end
end
