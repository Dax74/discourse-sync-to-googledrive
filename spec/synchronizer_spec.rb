describe ::Synchronizer do
  
  let(:backup) { Backup.new('backup') }

  describe "#backup" do
    it "has a reader method for the backup" do
      ds = described_class.new(backup)
      expect(ds.backup).to eq(backup)
    end
  end

  describe "#can_sync?" do
    it "should return false when disabled via site setting" do
      SiteSetting.discourse_backups_enabled = false
      SiteSetting.discourse_backups_api_key = 'test_key'
      ds = described_class.new(backup)
      expect(ds.can_sync?).to eq(false)
    end

    it "should return false when the backup is missing" do
      SiteSetting.discourse_backups_enabled = true
      SiteSetting.discourse_backups_api_key = 'test_key'
      ds = described_class.new(nil)
      expect(ds.can_sync?).to eq(false)
    end

    it "should return false when the api key is missing" do
      SiteSetting.discourse_backups_enabled = true
      SiteSetting.discourse_backups_api_key = ''
      ds = described_class.new(backup)
      expect(ds.can_sync?).to eq(false)
    end

    it "should return true when everything is correct" do
      SiteSetting.discourse_backups_enabled = true
      SiteSetting.discourse_backups_api_key = 'test_key'
      ds = described_class.new(backup)
      expect(ds.can_sync?).to eq(true)
    end
  end

  describe "#sync" do
  	context "it #can_sync" do
	  	it "should perform sync if it can" do
	  		ds = described_class.new(backup)
	  		ds.stub(:can_sync)
	  		ds.sync
	  		expect(ds).to have_received(:perform_sync)
	  	end
  	end
  end
end