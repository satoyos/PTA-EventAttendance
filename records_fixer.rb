# 出欠登録レコードの一つ一つについて、それぞれがどの生徒のものなのかを特定する

require_relative 'handle_csv_from_excel'
require_relative 'applied_record'
require_relative 'peer'
require 'json'
require 'pathname'
require 'logger'

class Student
  attr_accessor :presence, :attendee_number
end

class RecordsFixer
  GUESSING_LOG = './guessing.log'

  attr_reader :records, :peer, :log, :students_to_come

  def initialize(record_csv_path: nil)
    return unless record_csv_path
    @records = records_from_csv(record_csv_path)
  end

  def set_peer_from_files_in(peer_name, files_path_json: nil)
    @peer = Peer.new(peer_name)
    add_class_to_peer_from(peer, data_source_json: files_path_json)
    self
  end

  def guess_students(log_path=nil)
    log = Logger.new(log_path ? log_path : GUESSING_LOG)
    records.each_with_index do |rec, idx|
      next if rec.correct_student
      rec.correct_student, rec.penalty =
          peer.guess_who(class_name: rec.class_name, number: rec.number_in_class, name: rec.name)
      log.info(check_done_message(idx, rec))
      puts " - #{check_done_message(idx, rec)}"
    end
    log.close
    self
  end

  def save_confirmed_history(out_json_path)
    raise '確認済みデータを出力するファイルのパスを引数で指定してください。' unless out_json_path
    array_to_save = records.map{|rec| hash_to_save_from(rec)}
    File.open(out_json_path, 'w:utf-8') do |outfile|
      outfile.puts(JSON.pretty_generate(array_to_save))
    end
    self
  end


  def load_confirmed_data_and_check(in_json_path)
    hashes_from_json = get_hashes_from(in_json_path)
    raise 'CSVのデータ数が明らかに少ない！' if hashes_from_json.size > records.size
    hashes_from_json.each_with_index do |hash, idx|
      check_record_with_saved_data(records[idx], hash[:applied_record], index: idx)
      student_hash = hash[:correct_student]
      loaded_student = peer.fetch_student_of(class_name: student_hash[:class_name],
                                             number_in_class: student_hash[:number_in_class])
      records[idx].correct_student = loaded_student
    end

    self
  end

  def list_up_students_to_come
    @students_to_come = peer.all_students.select{|st|
      last_record = records.select{|rec| rec.correct_student == st}.last
      st.presence = last_record.presence if last_record
      st.attendee_number = last_record.attendee_number if last_record
      last_record ? last_record.presence : false
    }
    self
  end

  private

  def check_record_with_saved_data(record, hash_from_json, index: nil)
    raise ("CSVから読み込んだ#{index}番目のデータに食い違いがあります。\n" +
        "  downloaded CSV  => #{record.name}, " +
        "  saved_data_JSON => #{record.name}") unless
        (record.to_pseudo_student == Student.new(hash_from_json))
  end

  def get_hashes_from(in_json_path)
    raise '読み込む「確認済みJSONデータファイル」のパスを引数で指定してください。' unless in_json_path
    raise "与えられたパスのファイルが見つかりません。[#{in_json_path}]" unless File.exist? in_json_path
    load_str = nil
    open(in_json_path, 'r:utf-8'){|f| load_str = f.read}
    JSON.parse(load_str, symbolize_names: true)
  end

  def records_from_csv(csv_path)
    raise '出欠登録レコードCSVのパスを引数で指定してください。' unless csv_path
    raise "指定されたパスのファイルが見つかりません。[#{csv_path}]" unless File.exist? csv_path
    recs = []
    HandleCsvFromExcel.read_csv_file(csv_path).each do |row|
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
                     attendee_number: extract_attendie_number_in(row),
                     comment: row['コメント'],
                     date: Date.parse(row['回答日時']),
    )
  end

  def extract_attendie_number_in(row)
    return 0 unless row['参加人数']
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

  def add_class_to_peer_from(peer, data_source_json: nil)
    raise 'Peerオブジェクトを引数で指定してください。' unless peer.is_a? Peer
    raise '引数で、クラス名簿ファイルのパスが記述されたJSONファイルを指定してください。' unless data_source_json
    raise "指定されたパスのファイルが見つかりません。[#{data_source_json}]" unless File.exist? data_source_json
    open(data_source_json, 'r:utf-8') do |infile|
      json = JSON.parse(infile.read, symbolize_names: true)
      json.each do |hash|
        peer.add_class(Classroom.create_from_member_txt(
          member_list_file_path(data_source_json, hash[:file_path]),
          class_name: hash[:class_name]))
      end
    end
  end

  def member_list_file_path(data_source_json_path, each_class_relative_path)
    (Pathname(data_source_json_path).dirname + Pathname(each_class_relative_path)).to_s
  end

  def hash_to_save_from(record)
    {
        applied_record: {
          class_name: record.class_name,
          number_in_class: record.number_in_class,
          name: record.name
        },
        correct_student: {
            class_name: record.correct_student.class_name,
            number_in_class: record.correct_student.number_in_class,
            name: record.correct_student.name
        }
    }
  end

  def check_done_message(idx, rec)
    "#{idx+1}番目のレコード[#{rec.class_name}, #{rec.number_in_class}, #{rec.name}]をチェックしました"
  end
end