require_relative '../peer'

describe 'Peer' do
  describe '初期化' do
    let(:peer){Peer.new('セ・リーグ')}
    it 'should be a valid object' do
      expect(peer).not_to be nil
      expect(peer).to be_a Peer
    end
    it '名前が正しく設定されている' do
      expect(peer.name).to eq 'セ・リーグ'
    end
    it '初期化時には、学級の数はゼロ' do
      expect(peer.classes.size).to be 0
    end
  end

  describe '#add_class' do
    let(:peer){Peer.new('セ・リーグ')}
    it '与えられたClassroomオブジェクトを管理する学級群に加える' do
      peer.add_class(Classroom.new('中日'))
      expect(peer.classes.size).to be 1
      expect(peer.classes.first).to be_a Classroom
      peer.add_class(Classroom.new('阪神'))
      expect(peer.classes.size).to be 2
    end
  end

  describe '#guess_who' do
    MEMBER_TXT_TIGERS  = 'spec/member_ht1985.txt'
    MEMBER_TXT_DRAGONS = 'spec/member_cd1999.txt'
    MEMBER_TXT_GIANTS  = 'spec/member_yg1973.txt'
    let(:peer){Peer.new('セ・リーグ')}
    before do
      peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_TIGERS,  class_name: '阪神'))
      peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_DRAGONS, class_name: '中日'))
      peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_GIANTS,  class_name: '巨人'))
    end
    it 'メソッド呼び出し前の状態確認' do
      expect(peer.classes.size).to be 3
      expect(peer.classes.last.students.size).to be 18
    end
    it '2要素の配列を返す' do
      peer.guess_who(class_name: '巨人', number: 4, name: '長嶋茂雄').tap do |answer|
        expect(answer).to be_an Array
        expect(answer.size).to be 2
      end
    end
    context '完全に正しいヒントを与えたとき' do
      it '正しい生徒を推測でき、ペナルティの値は0になる' do
        student, penalty = peer.guess_who(class_name: '巨人', number: 4, name: '長嶋茂雄')
        expect(penalty).to be 0
        expect(student.number_in_class).to be 4
        expect(student.class_name).to eq '巨人'
      end
    end
    context 'クラス名を間違えた場合' do
      it '一般に名前が長いので、正しい生徒を推測できる' do
        student, penalty = peer.guess_who(class_name: '阪神', number: 2, name: '土井正三')
        expect(student.class_name).to eq '巨人'
        expect(student.number_in_class).to be 2
      end
    end
    context '名前を1文字間違えた場合' do
      it '正しい生徒を推測でき、ペナルティの値は2' do
        student, penalty = peer.guess_who(class_name: '中日', number: 6, name: '岩瀬仁xx')
        expect(student.class_name).to eq '中日'
        expect(student.number_in_class).to be 6
        expect(penalty).to be 2
      end
    end
  end

  describe '#fetch_student_of' do
    let(:peer){Peer.new('セ・リーグ')}
    before do
      peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_TIGERS,  class_name: '阪神'))
      peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_DRAGONS, class_name: '中日'))
      peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_GIANTS,  class_name: '巨人'))
    end
    context '正しい条件を与えられたとき' do
      it '条件に見合った生徒を返す' do
        peer.fetch_student_of(class_name: '阪神', number_in_class: 5).tap do |st|
          expect(st).to be_a Student
          expect(st.name).to eq '岡田彰布'
        end
      end
    end
    context 'クラス名や出席番号が間違っているとき' do
      it '例外が発生する' do
        expect{peer.fetch_student_of(class_name: '阪急', number_in_class: 5)}.to raise_error RuntimeError
        expect{peer.fetch_student_of(class_name: '阪神', number_in_class: 50)}.to raise_error RuntimeError
      end
    end
  end
end