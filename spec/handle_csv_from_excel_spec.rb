require_relative '../handle_csv_from_excel'
require 'pp'

TEST_CSV_PATH = 'spec/out-2016-06-02-test.csv' # セルの中に改行文字も入っているExcelから作った
TEST_RESULT_CSV = 'spec/out-2017-01-05-test.csv'

def clean_test_outflie_if_exist
  File.delete(TEST_RESULT_CSV) if File.exist?(TEST_RESULT_CSV)
end

describe 'HandleCsvFromExcel' do
  describe 'read_from_csv_file' do
    let(:csv){HandleCsvFromExcel.read_csv_file(TEST_CSV_PATH)}
    it 'csvプロパティでCSVデータを保持する' do
      expect(csv).not_to be nil
      expect(csv).to be_an CSV::Table
    end
    it 'データの中に改行が入っていても、きちんと一つのデータとしてくれている。' do
      expect(csv.size).to be 4
    end
    it 'ヘッダ行をうまく読み込めている' do
      csv.headers.tap do |h|
        expect(h).not_to be nil
        expect(h).to be_an Array
        expect(h.first).to eq '出欠'
        expect(h.last).to eq '回答日時'
      end
    end
    it 'データ行も正しく読み込めている' do
      csv[0].tap do |first|
        expect(first['クラス']).to eq '中日'
        expect(first['参加人数']).to eq '１名'
      end
    end
  end

  TEST_EXCEL_PATH = 'spec/out-2017-01-05-test.xls'

  describe 'convert_excel_to_csv' do

    before do
      clean_test_outflie_if_exist
    end
    it 'creates csv file from Excel' do
      HandleCsvFromExcel.convert_excel_to_csv(TEST_EXCEL_PATH)
      expect(File.exist? TEST_RESULT_CSV).to be true
    end
    after do
      clean_test_outflie_if_exist
    end
  end
end

