require_relative '../applied_record'

describe "AppledRecord" do
  describe '初期化' do
    context '引数無し' do
      let(:record){AppliedRecord.new}
      it 'should be a valid object' do
        expect(record).not_to be nil
      end
    end
    context '初期化データを与えて場合' do
      let(:record){AppliedRecord.new(
          name: '○○○子', parent_name: '○○×男', class: '阪急', number_in_class: 5,
          presence: true,
      )}
      it 'should be a valid object' do
        expect(record).to be_an AppliedRecord
      end
      it '初期化時に与えたデータが、パラメータとして設定されている' do
        expect(record.name).to eq '○○○子'
        expect(record.parent_name).to eq '○○×男'
        expect(record.class).to eq '阪急'
        expect(record.number_in_class).to be 5
        expect(record.presence).to be true
      end
      it '初期化時には、「正しい生徒」を表すプロパティの値は居設定' do
        expect(record.correct_student).to be nil
      end
    end
  end
end