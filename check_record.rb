require_relative 'records_fixer'
require_relative 'course'

# このファイルを、Excelデータが更新されるたびに書き換える
RECORD_CSV_PATH = File.join(ENV['RECORD_CSV_FOLDER'], 'out-2016-06-19.csv')

DATA_HEADER_IN_CLASS =  %w(# 氏名 出欠 参加人数 コース コメント)

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
  last_rec = records.select{|rec| rec.correct_student == st}.last
  return  [st.number_in_class, st.name, Array.new(DATA_HEADER_IN_CLASS.size - 1)] if last_rec.nil?
  return [st.number_in_class, st.name, presence_str_for(last_rec), attendee_number_for(last_rec),
          nil, last_rec.comment, nil] unless last_rec.presence
  [st.number_in_class, st.name,
   presence_str_for(last_rec), attendee_number_for(last_rec), st.course, last_rec.comment, nil]
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

def students_of_course(course_name, peer)
  peer.all_students.select{|st| st.course == course_name}
end

def course_data_of(idx=nil)
  raise '何番目のデータを出力するのかを引数で指定してください。' unless idx
  Course.all_courses.map{|course|
    student_data_of_course(course, )

  }
end

def csv_str_for_course(fixer)
  students_by_course = fixer.students_to_come.group_by{|st| st.course}
  max_students_num = students_by_course.values.map{|students| students.size}.max
  CSV.generate do |csv|
    #%ToDo: ここをちゃんと書く！
    csv <<  students_by_course.values.map{|students| students.size}
=begin
    (0..max_students_num-1).each do |idx|
      csv << course_data_of(idx)
    end
=end

  end
end

def csv_out_by_peer(path, peer, records, encoding: 'utf-8')
  File.open(path, 'w:'+encoding) do |outfile|
    outfile.puts csv_str_for_peer(peer, records)
  end
end

def csv_out_by_course(path, fixer, encoding: 'utf-8')
  File.open(path, 'w:'+encoding) do |outfile|
    outfile.puts csv_str_for_course(fixer)
  end
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