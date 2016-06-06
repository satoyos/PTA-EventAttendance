require_relative '../applied_record'

describe 'AppliedRecord' do
  describe '初期化' do
    context '引数無し' do
      let(:record){AppliedRecord.new}
      it 'should be a valid object' do
        expect(record).not_to be nil
      end
    end
    context '初期化データを与えて場合' do
      let(:record){AppliedRecord.new(
          name: '○○○子', parent_name: '○○×男', class_name: '阪急', number_in_class: 5, comment: '三冠王',
          presence: true, attendee_number: 1
      )}
      it 'should be a valid object' do
        expect(record).to be_an AppliedRecord
      end
      it '初期化時に与えたデータが、パラメータとして設定されている' do
        expect(record.name).to eq '○○○子'
        expect(record.parent_name).to eq '○○×男'
        expect(record.class_name).to eq '阪急'
        expect(record.number_in_class).to be 5
        expect(record.presence).to be true
        expect(record.attendee_number).to be 1
        expect(record.comment).to eq '三冠王'
      end
      it '初期化時には、「正しい生徒」を表すプロパティの値は居設定' do
        expect(record.correct_student).to be nil
      end
    end
  end

  describe '#to_pseudo_student' do
    let(:record){AppliedRecord.new(
        name: '○○○子', parent_name: '○○×男', class_name: '阪急', number_in_class: 5, comment: '三冠王',
        presence: true, attendee_number: 1
    )}
    it 'このレコードのデータを元に作成した仮オブジェクトを作る' do
      record.to_pseudo_student.tap do |p_st|
        expect(p_st).to be_a Student
        expect(p_st).to eq Student.new(name: '○○○子', number_in_class: 5, class_name: '阪急')
      end

    end
  end
end