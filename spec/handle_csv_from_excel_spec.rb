require_relative '../handle_csv_from_excel'
require 'pp'

TEST_CSV_PATH = 'spec/out-2016-06-02-test.csv' # セルの中に改行文字も入っているExcelから作った

describe 'CSVファイルの読み込み' do
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