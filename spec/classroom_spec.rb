require_relative '../classroom'

describe 'Classroom' do
  let(:cr){Classroom.new('1組')}
  describe '初期化' do
    it 'should be a valid object' do
      expect(cr).not_to be nil
      expect(cr).to be_a Classroom
    end
    it '初期化時に与えたデータがプロパティに正しく設定されている' do
      expect(cr.name).to eq '1組'
    end
  end

  describe '#students' do
    it '配列を返す' do
      expect(cr.students).to be_an Array
    end
  end

  describe '#add_student' do
    it '生徒一人分のデータを追加する' do
      cr.add_students(Student.new(name: '○×△', number_in_class: 10))
      expect(cr.students.size).to be 1
      cr.students.first.tap do |st|
        expect(st).to be_a Student
        expect(st.name).to eq '○×△'
        expect(st.number_in_class).to be 10
        expect(st.class_name).to eq '1組'
      end
    end
  end

  describe '#guess_who' do
    let(:class_ht){Classroom.create_from_member_txt(TEST_MEMBER_TXT_PATH, class_name: '阪神')}
    let(:answer_1){class_ht.guess_who(class_name: '阪神', number: 3, name: 'バース')}
    describe '与えられたデータに一番近い(誤りによるペナルティが小さい)生徒を返す' do
      it 'データは2要素の配列で返す' do
        expect(answer_1).to be_an Array
        expect(answer_1.size).to be 2
      end
      it '生徒「バース」を1つめの要素として返す' do
        answer_1[0].tap do |st|
          expect(st).to be_a Student
          expect(st.name).to eq 'バース'
          expect(st.number_in_class).to be 3
        end


      end
      it '誤りが全く無い場合は、ペナルティの値が0' do
        expect(answer_1[1]).to be 0
      end
      context '出席番号が与えられない場合' do
        it '他のデータが合っていたら、ペナルティの値は2' do
          student, penalty = class_ht.guess_who(class_name: '阪神', number: nil, name: 'バース')
          expect(student.number_in_class).to be 3
          expect(penalty).to be 2
        end
      end
      context '出席番号が間違っている場合' do
        it '名前が長いので、名前のマッチングの方が優先される' do
          student, penalty = class_ht.guess_who(class_name: '阪神', number: 12, name: '掛布雅之')
          expect(student.number_in_class).to be 4
          expect(penalty).to be 2
        end
      end
      context '名前から1文字抜けた場合' do
        it '正常に候補を挙げられ、ペナルティは0' do
          student, penalty = class_ht.guess_who(class_name: '阪神', number: 1, name: '真弓信')
          expect(student.number_in_class).to be 1
          expect(penalty).to be 0
        end
      end
      context '名前に1文字ノイズが乗った場合' do
        it '正常に候補を挙げられ、ペナルティは3' do
          student, penalty = class_ht.guess_who(class_name: '阪神', number: 12, name: '吉田義男○')
          expect(student.number_in_class).to be 12
          expect(penalty).to be 3
        end
      end
    end
  end

  describe 'クラスメソッド create_from_member_txt' do
    TEST_MEMBER_TXT_PATH = 'spec/member_ht1985.txt'
    let(:cr){Classroom.create_from_member_txt(TEST_MEMBER_TXT_PATH, class_name: '阪神')}
    it 'should be a valid object' do
      expect(cr).not_to be nil
      expect(cr.name).to eq '阪神'
    end
    it '12人分の生徒データを読み込めている' do
      expect(cr.students.size).to be 12
      expect(cr.students.first).to be_a Student
    end
    it '出席番号3番の生徒はバース' do
      cr.students[2].tap do |third|
        expect(third.name).to eq 'バース'
        expect(third.number_in_class).to be 3
        expect(third.class_name).to eq '阪神'
      end
    end
  end
end