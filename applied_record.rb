# 出欠登録データを1件ごとに監視するオブジェクト

class AppliedRecord
  attr_accessor :name, :parent_name, :class, :number_in_class, :presence
  attr_accessor :number_to_come, :comment
  attr_accessor :correct_student

=begin
  def initialize(init_hash={})
    init_hash.each do |key, value|
      raise "プロパティ#{key}はサポートしていません。" unless self.respond_to? "#{key}="
      self.send("#{key}=", value)
    end
  end
=end
end