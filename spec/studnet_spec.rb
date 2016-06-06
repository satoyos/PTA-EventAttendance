require_relative '../student'

describe 'student' do
  sample_name = '○○太郎'
  sample_number = 14
  describe '初期化' do
    let(:student){Student.new}
    it 'should be a valid object' do
      expect(student).not_to be nil
      expect(student).to be_a Student
    end
    context 'プロパティの初期化も行う'do
      let(:student){Student.new(name: sample_name, number_in_class: sample_number)}
      it 'プロパティの値が正しく設定されている' do
        expect(student.name).not_to be nil
        expect(student.name).to eq sample_name
        expect(student.number_in_class).to eq sample_number
      end
    end
    context 'クラス名を与えても良い' do
      let(:student){Student.new(name: sample_name, number_in_class: sample_number, class_name: 'A組')}
      it 'should be a valid object' do
        expect(student).to be_a Student
      end
      it 'クラス名が正しく設定されている' do
        expect(student.class_name).to eq 'A組'
      end
    end
  end

  describe '#to_s' do
    let(:student){Student.new(name: sample_name, number_in_class: sample_number)}
    it 'オブジェクトの内容を文字列化して返す' do
      expect(student.to_s).to be_a String
      expect(student.to_s).to eq '[14] ○○太郎'
    end
  end

  describe '#eql?' do
    sample_class = 'B組'
    let(:st1){Student.new(name: sample_name, number_in_class: sample_number, class_name: sample_class)}
    let(:st2){Student.new(name: sample_name, number_in_class: sample_number, class_name: sample_class)}
    it '内容が一致していれば、eql?が成立するものとする。' do
      expect(st1.eql? st2).to be true
    end
  end
end