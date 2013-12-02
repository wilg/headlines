class TemporaryHeadline

  attr_accessor :name

  def initialize(name)
    self.name = name
  end

  def salted_hash
    Headline.salted_hash(name)
  end

  def persisted?
    false
  end

end