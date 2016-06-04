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
          expect(recs.size).to be 3
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
end