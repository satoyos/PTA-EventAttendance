module InitWithHash
  def initialize(init_hash={})
    init_hash.each do |key, value|
      raise "プロパティ#{key}はサポートしていません。" unless self.respond_to? "#{key}="
      self.send("#{key}=", value)
    end
  end
end