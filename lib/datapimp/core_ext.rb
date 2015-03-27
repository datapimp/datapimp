class Hash
  def to_mash
    Hashie::Mash.new(self)
  end
end
