require_relative '../records_fixer'

describe 'RecordsFixer' do
  describe '初期化' do
    context '引数無しで初期化した場合' do
      let(:fixer){RecordsFixer.new}
      it 'should be a valid object' do
        expect(fixer).not_to be nil
      end
    end
    context '出欠登録レコードのファイルパスを与えて初期化する' do
      let(:fixer){RecordsFixer.new(record_csv_path: 'spec/out-2016-06-02-test.csv')}
      it 'should be a RecordFixter' do
        expect(fixer).to be_a RecordsFixer
      end
      it '出欠レコードを与えられたファイルから読み込んでいる' do
        fixer.records.tap do |recs|
          expect(recs).to be_an Array
          # expect(recs.size).to be 3
          recs.first.tap do |r|
            expect(r).to be_an AppliedRecord
            expect(r.name).to eq '山田洋'
            expect(r.number_in_class).to be 16
            expect(r.class_name).to eq '中日'
            expect(r.presence).to be true
            expect(r.parent_name).to eq '山田耕筰'
            expect(r.attendee_number).to be 1
            expect(r.comment).to eq 'Eコース: オーストリア'
            expect(r.date).to eq Date.new(2016, 6, 2)
          end
        end
      end
    end
  end

  describe '#fetch_correct_peer_data' do
    let(:fixer){
      RecordsFixer.new(record_csv_path: 'spec/out-2016-06-02-test.csv').
          fetch_correct_peer_data('セ・リーグ', files_path_json: 'spec/class_files_path.json')
    }
    it 'gets peer data from given file' do
      fixer.peer.tap do |p|
        expect(p).to be_a Peer
        # expect(p.classes.size).to be 3
        p.classes.first.tap do |first_class|
          expect(first_class).to be_a Classroom
          expect(first_class.students.size).to be 23
        end
      end
    end
  end

  describe '#guess_students' do
    let(:fixer){
      RecordsFixer.new(record_csv_path: 'spec/out-2016-06-02-test.csv').
          fetch_correct_peer_data('セ・リーグ', files_path_json: 'spec/class_files_path.json').
          guess_students
    }
    it 'returns a valid object' do
      expect(fixer).to be_a RecordsFixer
    end
    it '各レコードに対して、想定通りの生徒を推測できている' do
      fixer.records.first.correct_student.tap do |first_student|
        expect(first_student).to be_a Student
        expect(first_student.name).to eq '山田洋'
        expect(first_student.number_in_class).to be 16
        expect(first_student.class_name).to eq '中日'
      end
      expect(fixer.records.first.penalty).to be 0
    end
    it '3番目の全角スペース入りのレコードも、問題なし' do
      fixer.records[2].correct_student.tap do |third_student|
        expect(third_student.class_name).to eq '阪神'
        expect(third_student.number_in_class).to be 4
        expect(third_student.name).to eq '掛布雅之'
      end
    end
    it '3番目のレコードまでは、全てペナルティ0' do
      expect(fixer.records[0..2].map{|r| r.penalty}).to eq [0, 0, 0]
    end
  end
end