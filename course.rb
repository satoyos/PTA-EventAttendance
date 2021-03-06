require_relative 'peer'
require 'json'

class Student
  attr_accessor :course
end

class Course
  attr_reader :name, :students
  def initialize(course_name)
    @students = []
    @name = course_name
  end

  def add_student(student)
    raise '学生データを引数で指定してください。' unless student.is_a? Student
    @students << student
  end

  class << self
    attr_accessor :all_courses

    def create_from_member_txt(txt_path, course_name: nil, peer: nil)
      raise 'コースの名称を引数で指定してください。' unless course_name
      raise 'コースに参加する生徒一覧のテキストファイルを引数で指定してください。' unless txt_path
      raise "引数で指定されたパスのファイルが見つかりません。[#{txt_path}]" unless File.exist? txt_path
      raise '学年の生徒データを保持するPeerオブジェクトを引数で指定してください。' unless peer
      self.new(course_name).read_students_from_txt(txt_path, peer)
    end

    def read_courses_from_json(json_path, peer: nil, options: {})
      raise 'コース名簿ファイルの一覧を記載したJSONファイルをパスで指定してください' unless json_path
      raise "引数で指定されたパスのファイルが見つかりません。[#{json_path}]" unless File.exist? json_path
      encoding = options[:encoding] ? options[:encoding] : 'utf-8'
      self.all_courses = nil
      open(json_path, 'r:' + encoding) do |f|
        self.all_courses = JSON.parse(f.read, symbolize_names: true).map{|course_hash|
          create_from_member_txt(File.join(File.dirname(json_path), course_hash[:file_path]),
          course_name: course_hash[:course], peer: peer)
        }
      end
      self.all_courses
    end
  end

  def read_students_from_txt(txt_path, peer)
    open(txt_path, 'r:utf-8') do |infile|
      while (line = infile.gets)
        break if line.strip!.nil? or line.length < 1
        m = line.match(/\A(\S+)\s+([0-9]+)\s+(\S+)\z/)
        raise "行データからクラス名、出席番号と名前を読み取れませんでした。\n => #{[line]}" unless m
        guessed_student = peer.guess_who(class_name: m[1], number: m[2].to_i, name: m[3])[0]
        guessed_student.course = self.name.to_sym
        self.add_student(guessed_student)
      end
    end
    self
  end
end
