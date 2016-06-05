# 「学年」クラス

require_relative 'classroom'

class Peer
  attr_reader :name, :classes

  def initialize(name)
    @name = name
    @classes = []
  end

  def add_class(classroom)
    @classes << classroom
  end

  def guess_who(class_name: nil, number: nil, name: nil)
    raise 'クラス名を引数で指定してください。' unless class_name
    raise '生徒名を引数で指定してください。' unless name
    classes.map{|cr|
      cr.guess_who(class_name: class_name, number: number, name: name)
    }.sort{|a, b| a[1] <=> b[1]}.first
  end

  def fetch_student_of(class_name: nil, number_in_class: nil)
    raise 'クラス名を引数で指定してください。' unless class_name
    raise '出席番号を引数で指定してください。' unless number_in_class
    valid_class = classes.find{|cr| cr.name == class_name}
    raise "指定されたクラス名[#{class_name}のクラスがありません。]" unless valid_class
    valid_student = valid_class.students.find{|st| st.number_in_class == number_in_class}
    raise "指定された出席番号[#{number_in_class}の生徒がクラス[#{class_name}]で見つかりません" unless valid_student
    valid_student
  end
end