# 生徒を管理する
require_relative 'init_with_hash_module'

class Student
  include InitWithHash

  attr_accessor :name, :number_in_class, :class_name

  def to_s
    '[%02d] %s' % [number_in_class, name]
  end
end