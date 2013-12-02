class Generator

  def self.generate!(sources, depth = 2)
    `python #{Rails.root}/lib/markov.py #{depth} #{sources.join(" ")}`.lines.map(&:chomp).map(&:grubercase).map{|h| TemporaryHeadline.new(h) }
  end

end