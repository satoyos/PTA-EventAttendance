require_relative 'records_fixer'

# このファイルを、Excelデータが更新されるたびに書き換える
RECORD_CSV_PATH = File.join(ENV['RECORD_CSV_FOLDER'], 'out-2016-06-12.csv')

DATA_HEADER_IN_CLASS =  %w(# 氏名 出欠 参加人数 コメント)
# DATA_HEADER_IN_CLASS =  %w(# 氏名 出欠 参加人数)

# 生徒の名寄せチェック済みのデータファイル。
# 新規に追加されたものについては、間違っているかもしれないので、
# その場合にはクラスと出席番号を手で書き直す。
def confirm_history_json
  ENV['CONFIRM_HISTORY_JSON_PATH'] ||
    raise('環境変数[CONFIRM_HISTORY_JSON_PATH]で、生徒の名寄せチェック済みのデータファイルを指定してください。')
end

# クラス毎の生徒一覧ファイル(へのパス)を、全クラス分記載したファイル。
def class_member_files_list_json
  ENV['CLASS_MEMBER_FILES_LIST_PATH'] ||
    raise('環境変数[CLASS_MEMBER_FILES_LIST_PATH]で、 クラス毎の生徒一覧ファイル(へのパス)を、全クラス分記載したファイルを指定してください。')
end

# 集計結果CSVの出力フォルダ
def output_csv_folder
  ENV['OUTPUT_CSV_FOLDER'] ||
      raise('環境変数[OUTPUT_CSV_FOLDER]で、 集計結果CSVを出力するフォルダを指定してください。')
end

def peer_header(peer)
  peer.classes.map{|cr| [cr.name + '組'] + Array.new(DATA_HEADER_IN_CLASS.size)}.flatten
end

def classroom_header(peer)
  peer.classes.map{|cr| DATA_HEADER_IN_CLASS + Array.new(1)}.flatten
end

def presence_str_for(record)
  record.presence ? '○' : '×'
end

def attendee_number_for(record)
  record.presence ? record.attendee_number : nil
end

def student_data_of_class(cr, idx: nil, records: [])
  return Array.new(DATA_HEADER_IN_CLASS.size + 1) if (st = cr.students[idx]).nil?
  last_record = records.select{|rec| rec.correct_student == st}.last
  return  [st.number_in_class, st.name, Array.new(DATA_HEADER_IN_CLASS.size - 1)] if last_record.nil?
  [st.number_in_class, st.name,
   presence_str_for(last_record), attendee_number_for(last_record), last_record.comment, nil]
end

def classroom_data_of(peer, idx: nil, records: nil)
  peer.classes.map{|cr|
    student_data_of_class(cr, idx: idx, records: records)
  }.flatten
end

def csv_str_for_peer(peer, records)
  max_students_num = peer.classes.map{|cr| cr.students.size}.max
  CSV.generate do |csv|
    csv << peer_header(peer)
    csv << classroom_header(peer)
    (0..max_students_num-1).each do |idx|
      csv << classroom_data_of(peer, idx: idx, records: records)
    end
  end
end

def csv_out_peer_for_excel(path, peer, records)
  File.open(path, 'w:windows-31j') do |outfile|
    outfile.puts csv_str_for_peer(peer, records)
  end
end

fixer = RecordsFixer.new(record_csv_path: RECORD_CSV_PATH).
    set_peer_from_files_in('高2', files_path_json: class_member_files_list_json ).
    load_confirmed_data_and_check(confirm_history_json).
    guess_students.save_confirmed_history(confirm_history_json)

csv_out_peer_for_excel(File.join(output_csv_folder, 'クラス別出欠状況.csv'),
                       fixer.peer, fixer.records)

puts "\n【正常終了】"