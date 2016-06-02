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
end