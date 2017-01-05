require 'csv'
require 'win32ole'


# 定数のロード
module Excel; end

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

    def read_excel_file(excel_path)
      out_csv_path = excel_path.gsub(/xls/, 'csv')
      convert_excel(excel_path, to_csv: out_csv_path)
      read_csv_file(out_csv_path)
    end

    def convert_excel(excel_path, to_csv: nil)
      raise '初期化パラーメータとして、Excelファイルのパスを指定してください' unless excel_path
      raise '変換後のCSVファイルのパスを指定してください' unless to_csv
      raise "指定されたパスのファイルが見つかりません。[#{excel_path}]" unless File.exist?(excel_path)
      puts "out_csv_path => [#{convert_path_for_windows(to_csv)}]"

      begin
        excel = WIN32OLE.new('Excel.Application')

        WIN32OLE.const_load(excel, Excel)

        workbook = excel.workbooks.open(convert_path_for_windows excel_path)
        first_sheet = workbook.sheets[1] # CSVに変換する対象は、最初のシート。
        first_sheet.SaveAs(convert_path_for_windows(to_csv), Excel::XlCSV);
      rescue => ex
        print ex.message.encode('utf-8', 'windows-31j'), "\n"
      ensure
        workbook.close('SaveChanges' => false) if workbook
        excel.quit if excel
      end
    end

    def convert_path_for_windows(path)
      File.expand_path(path).gsub(/\//, "\\")
    end
  end

end