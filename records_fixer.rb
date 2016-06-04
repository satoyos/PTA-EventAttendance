# 出欠登録レコードの一つ一つについて、それぞれがどの生徒のものなのかを特定する

require_relative 'handle_csv_from_excel'
require_relative 'applied_record'

class RecordsFixer
  attr_reader :records

  def initialize(record_csv_path: nil)
    return unless record_csv_path
    @records = records_from_csv(record_csv_path)
  end

  private

  def records_from_csv(csv_path)
    raise '出欠登録レコードCSVのパスを引数で指定してください。' unless csv_path
    raise "指定されたパスのファイルが見つかりません。[#{csv_path}]" unless File.exist? csv_path
    recs = []
    HandleCsvFromExcel.new(csv_path).csv.each do |row|
      recs << record_from_row(row)
    end
    recs
  end

  def record_from_row(row)
    AppliedRecord.new(
                     name: row['在校生氏名'],
                     number_in_class: row['出席番号'].to_i,
                     class_name: row['クラス'],
                     presence: (row['出欠'] == '出席'),
                     parent_name: row['保護者氏名'],
                     attendee_number: extract_attendie_number(row),
                     comment: row['コメント'],
                     date: Date.parse(row['回答日時']),
    )
  end

  def extract_attendie_number(row)
    m = row['参加人数'].match(/(\S+)名/)
    return 0 unless m
    case m[1]
      when '１' ; 1
      when '２' ; 2
      when '３' ; 3
      when '４' ; 4
      when '５' ; 5
      when '６' ; 6
      when '７' ; 7
      when '８' ; 8
      when '９' ; 9
      else ; raise "文字列[#{m[1]}]から数字を抽出できません。"
    end
  end


end