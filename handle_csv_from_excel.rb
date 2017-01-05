require 'csv'

class HandleCsvFromExcel
  class << self
    def read_csv_file(path)
      raise '初期化パラーメータとして、CSVファイルのパスを指定してください' unless path
      raise "指定されたパスのファイルが見つかりません。[#{path}]" unless File.exist?(path)
      csv = nil
      open(path, 'r:windows-31j') do |f|
        str = f.read.encode('UTF-8')
        csv = CSV.parse(str, headers: true)
      end
      csv
    end
  end
end