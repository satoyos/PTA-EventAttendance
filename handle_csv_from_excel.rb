require 'csv'

class HandleCsvFromExcel
  attr_reader :csv

  def initialize(path)
    raise '初期化パラーメータとして、CSVファイルのパスを指定してください' unless path
    raise "指定されたパスのファイルが見つかりません。[#{path}]" unless File.exist?(path)
    @csv = read_csv_file(path)
  end

  private

  def read_csv_file(path)
    csv = nil
    open(path, 'r:windows-31j') do |f|
      str = f.read.encode('UTF-8')
      csv = CSV.parse(str, headers: true)
    end
    csv
  end
end