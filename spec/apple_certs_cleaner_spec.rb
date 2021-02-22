RSpec.describe AppleCertsCleaner do
  it "has a version number" do
    expect(AppleCertsCleaner::VERSION).not_to be nil
  end

  xit "remove pp file" do
    AppleCertsCleaner.remove_expired_provisioning_profile
  end

  xit "remove cert file" do
    AppleCertsCleaner.remove_expired_certificate
  end

  xit "remove invalid cert file" do
    AppleCertsCleaner.remove_invalid_certificate
  end
end


