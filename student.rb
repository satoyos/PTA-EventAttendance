# 生徒を管理する
class Student
  attr_accessor :name, :number_in_class, :class_name
  def initialize(init_hash={})
    init_hash.each do |key, value|
      raise "プロパティ[#{key}]は扱えません。" unless self.respond_to? "#{key}="
      self.send("#{key}=", value)
    end
  end

  def to_s
    '[%02d] %s' % [number_in_class, name]
  end
end