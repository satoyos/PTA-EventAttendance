# 出欠登録データを1件ごとに監視するオブジェクト

require_relative 'init_with_hash_module'
require_relative 'student'
require 'date'

class AppliedRecord
  include InitWithHash

  attr_accessor :name, :parent_name, :class_name, :number_in_class, :presence
  attr_accessor :attendee_number, :comment, :date
  attr_accessor :correct_student, :penalty

  def to_pseudo_student
    Student.new(name: name, number_in_class: number_in_class, class_name: class_name)
  end

end