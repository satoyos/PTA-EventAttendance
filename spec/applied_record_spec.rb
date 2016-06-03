require_relative '../applied_record'

describe "AppledRecord" do
  describe '初期化' do
    let(:record){AppliedRecord.new}
    it 'should be a valid object' do
      expect(record).not_to be nil
    end
  end
end