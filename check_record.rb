require_relative 'records_fixer'
require_relative 'course'
require_relative 'csv_out_by_classroom'
include CsvOutByClassroom
require_relative 'csv_out_by_course'
include CsvOutByCourse

# このファイルを、Excelデータが更新されるたびに書き換える
RECORD_CSV_PATH = File.join(ENV['RECORD_CSV_FOLDER'], 'out-2016-06-24.csv')

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

# コース毎の生徒一覧ファイル(へのパス)を、全コース分記載したファイル。
# 「コース」情報は、今回のイベント固有の情報
def course_member_files_list_json
  ENV['COURSE_MEMBER_FILES_LIST_PATH']
end

# 集計結果CSVの出力フォルダ
def output_csv_folder
  ENV['OUTPUT_CSV_FOLDER'] ||
      raise('環境変数[OUTPUT_CSV_FOLDER]で、 集計結果CSVを出力するフォルダを指定してください。')
end

def presence_str_for(record)
  record.presence ? '○' : '×'
end

def attendee_number_for(record)
  record.presence ? record.attendee_number : nil
end


fixer = RecordsFixer.new(record_csv_path: RECORD_CSV_PATH).
    set_peer_from_files_in('高2', files_path_json: class_member_files_list_json ).
    load_confirmed_data_and_check(confirm_history_json).
    guess_students.list_up_students_to_come.
  save_confirmed_history(confirm_history_json)

Course.read_courses_from_json(course_member_files_list_json, peer: fixer.peer)

csv_out_by_peer(File.join(output_csv_folder, 'クラス別出欠状況.csv'),
                fixer.peer, fixer.records, encoding: 'windows-31j')

csv_out_by_course(File.join(output_csv_folder, 'コース別出欠状況.csv'),
                  fixer, encoding: 'windows-31j')

puts "\n【正常終了】"