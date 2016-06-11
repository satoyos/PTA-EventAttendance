require_relative 'records_fixer'

# このファイルを、Excelデータが更新されるたびに書き換える
RECORD_CSV_PATH = File.join(ENV['RECORD_CSV_FOLDER'], 'out-2016-06-10.csv')

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

fixer = RecordsFixer.new(record_csv_path: RECORD_CSV_PATH).
    set_peer_from_files_in('高2', files_path_json: class_member_files_list_json ).
    load_confirmed_data_and_check(confirm_history_json).
    guess_students.save_confirmed_history(confirm_history_json)

puts "\n【正常終了】"