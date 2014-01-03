smoke "Datapimp Configuration" do
  it "should have a config file" do
    !Datapimp.config.config_file.nil?
  end

  it "should have a configuration profile" do
    !Datapimp.config.profile.nil?
  end
end
