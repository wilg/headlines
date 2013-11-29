class Source

  attr_accessor :name, :default, :id

  def self.load(hash)
    hash.map do |k, v|
      s = Source.new
      s.id = k.to_sym
      s.name = v['name']
      s.default = !!v['default']
      s
    end
  end

  def self.find_all(ids)
    ids.map{|id| find(id) }.compact
  end

  def self.find(id)
    all.bsearch{|source| source.id == id.to_sym}
  end

  @@all_sources = nil
  def self.all
    @@all_sources ||= Source.load(YAML.load_file(File.join(Rails.root, "config", "sources.yml")))
  end

end