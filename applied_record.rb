# 出欠登録データを1件ごとに監視するオブジェクト

require_relative 'init_with_hash_module'

class AppliedRecord
  include InitWithHash

  attr_accessor :name, :parent_name, :class_name, :number_in_class, :presence
  attr_accessor :attendee_number, :comment
  attr_accessor :correct_student

end