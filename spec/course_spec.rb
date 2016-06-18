require_relative '../course'


describe 'Course' do
  MEMBER_TXT_TIGERS  = 'spec/member_ht1985.txt'
  MEMBER_TXT_DRAGONS = 'spec/member_cd1999.txt'
  MEMBER_TXT_GIANTS  = 'spec/member_yg1973.txt'
  let(:peer){Peer.new('セ・リーグ')}
  before do
    peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_TIGERS,  class_name: '阪神'))
    peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_DRAGONS, class_name: '中日'))
    peer.add_class(Classroom.create_from_member_txt(MEMBER_TXT_GIANTS,  class_name: '巨人'))
  end
  describe '初期化' do
    let(:course){Course.new('somewhere')}
    it 'should be a valid object' do
      expect(course).to be_an Course
    end
  end

  describe 'クラスメソッド create_from_member_txt' do
    TEST_MEMBER_TXT_PATH = 'spec/camp/naha.txt'
    let(:course){Course.create_from_member_txt(TEST_MEMBER_TXT_PATH, course_name: '那覇', peer: peer)}
    it 'should be a valid object' do
      expect(course).to be_a Course
      expect(course.name).to eq '那覇'
    end
    it '4人分の生徒データを読み込めている' do
      expect(course.students.size).to be 4
      expect(course.students.first).to be_a Student
    end
    it '2番目の生徒はバース' do
      course.students[1].tap do |second|
        expect(second.name).to eq 'バース'
        expect(second.number_in_class).to be 3
        expect(second.class_name).to eq '阪神'
      end
    end
  end

end