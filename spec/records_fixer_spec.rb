require_relative '../records_fixer'

describe 'RecordsFixer' do
  describe '初期化' do
    let(:fixer){RecordsFixer.new}
    it 'should be a valid object' do
        expect(fixer).not_to be nil
    end
  end
end