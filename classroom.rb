require_relative 'student'

class Classroom
  attr_reader :name, :students

  def initialize(class_name)
    @name = class_name
    @students = []
  end

  def add_students(st)
    st.class_name = name
    @students << st
  end

  class << self
    def create_from_member_txt(txt_path, class_name: nil)
      raise '生徒の出席番号と名前を1行毎に列挙したテキストファイルのパスを指定してください' unless txt_path
      raise "指定されたパスのファイガ見つかりません。[#{txt_path}]" unless File.exist?(txt_path)
      raise 'クラスの名前を引数で指定してください。' unless class_name
      self.new(class_name).read_students_from_txt(txt_path)
    end
  end

  def read_students_from_txt(txt_path)
    open(txt_path, 'r:utf-8') do |infile|
      while (line = infile.gets)
        break if line.length < 1
        m = line.strip!.match(/\A([0-9]+)\s+(\S+)\z/)
        raise "行データから出席番号と名前を読み取れませんでした。\n => #{[line]}" unless m
        self.add_students(Student.new(name: m[2], number_in_class: m[1].to_i))
      end
    end
    self
  end

  def guess_who(class_name: nil, number: nil, name: nil)
    raise 'クラス名を引数で指定してください。' unless class_name
    raise '生徒名を引数で指定してください。' unless name
    num_str = number ? number.to_s : 'xx'
    min_penalty = 1000
    guessed_student = nil
    students.each do |st|
      penalty =
          (given_str(class_name, name.gsub(/　/, ''), num_str).unpack('C*') -
           correct_str(st).unpack('C*')).size
      if penalty < min_penalty
        min_penalty = penalty
        guessed_student = st
      end
    end
    [guessed_student, min_penalty]
  end

  private

  def correct_str(st)
    self.name + st.to_s
  end

  def given_str(class_name, name, num_str)
    class_name + '[%s] %s' % [num_str, name]
  end



end