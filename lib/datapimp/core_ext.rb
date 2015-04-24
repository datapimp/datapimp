class Hash
  def to_mash
    Hashie::Mash.new(self)
  end
end

class Pathname
  def to_pathname
    self
  end
end

class String
  def to_pathname
    Pathname(self)
  end

  def without_leading_slash
    gsub(/^\//,'')
  end

  def with_leading_slash
    "/#{without_leading_slash}"
  end
end
