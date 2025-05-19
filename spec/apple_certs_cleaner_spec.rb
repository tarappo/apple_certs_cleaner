RSpec.describe AppleCertsCleaner do
  it "has a version number" do
    expect(AppleCertsCleaner::VERSION).not_to be nil
  end

  it "remove expired pp file" do
    profiles = [
      { app_id_name: "TestApp1", file_path: "/tmp/app1.mobileprovision", limit_days: -2 },
      { app_id_name: "TestApp2", file_path: "/tmp/app2.mobileprovision", limit_days: 3 },
      { app_id_name: "TestApp3", file_path: nil, limit_days: -1 }
    ]

    allow(AppleCertsInfo).to receive(:provisioning_profile_list).and_return(profiles)
    allow(File).to receive(:delete)

    AppleCertsCleaner.remove_expired_provisioning_profile

    expect(File).to have_received(:delete).with("/tmp/app1.mobileprovision").once
  end

  it "remove expired cert file" do
    certs = [
      { cname: "CertA", limit_days: -1 },
      { cname: "CertB", limit_days: 5 },
      { cname: "CertC", limit_days: -10 }
    ]

    allow(AppleCertsCleaner).to receive(:all_certs_list).and_return(certs)
    allow(AppleCertsCleaner).to receive(:delete_first_match_keychain)

    AppleCertsCleaner.remove_expired_certificate

    expect(AppleCertsCleaner).to have_received(:delete_first_match_keychain).with(name: "CertA")
    expect(AppleCertsCleaner).to have_received(:delete_first_match_keychain).with(name: "CertC")
    expect(AppleCertsCleaner).to have_received(:delete_first_match_keychain).twice
  end

  xit "remove duplicate cert file" do
    AppleCertsCleaner.remove_duplicate_certificate
  end

  xit "remove invalid cert file" do
    AppleCertsCleaner.remove_invalid_certificate
  end
end


