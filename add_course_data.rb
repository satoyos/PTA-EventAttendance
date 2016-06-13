require_relative 'peer'
require 'json'

class Student
  attr_accessor :course
end

def add_course_to_peer_from(peer, data_source_json)
  raise 'Peerオブジェクトを引数で指定してください。' unless peer.is_a? Peer
  raise '引数で、コース毎の名簿ファイルのパスが記述されたJSONファイルを指定してください。' unless data_source_json
  raise "指定されたパスのファイルが見つかりません。[#{data_source_json}]" unless File.exist? data_source_json
  open(data_source_json, 'r:utf-8') do |infile|
    json = JSON.parse(infile.read, symbolize_names: true)
    json.each do |hash|
      add_each_course_to_peer(peer, course: hash[:course],
                              list_txt_path: File.join(File.dirname(data_source_json),
                                                       hash[:file_path]))
    end
  end
end

def add_each_course_to_peer(peer, course: nil, list_txt_path: nil)
  raise 'Peerオブジェクトを引数で指定してください。' unless peer.is_a? Peer
  raise '引数でコース名を指定してください' unless course
  raise '引数で、コース名簿ファイルのパスを指定してください。' unless list_txt_path
  raise "指定されたパスのファイルが見つかりません。[#{list_txt_path}]" unless File.exist? list_txt_path
  open(list_txt_path, 'r:utf-8') do |infile|
    while (line = infile.gets)
      break if line.strip!.nil? or line.length < 1
      m = line.match(/\A(\S+)\s+([0-9]+)\s+(\S+)\z/)
      raise "行データからクラス名、出席番号、名前を読み取れませんでした。\n => #{[line]}" unless m
      guessed_student, penalty = peer.guess_who(class_name: m[1], number: m[2].to_i, name: m[3])
      raise "この人が誰か推測できませんでした。 => クラス: #{m[1]}, 出席番号: #{m[2]}, 氏名: #{m[3]}" unless guessed_student
      guessed_student.course = course.to_sym
    end
  end
end

