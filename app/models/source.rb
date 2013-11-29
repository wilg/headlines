class Source

  attr_accessor :name, :default, :id, :category

  def self.load(hash)
    hash.map do |k, v|
      s = Source.new
      s.id = k.to_sym
      s.name = v['name']
      s.category = v['category']
      s.default = !!v['default']
      s
    end
  end

  def self.find_all(ids)
    ids.map{|id| find(id) }.compact
  end

  def self.find(id)
    all.find{|source| source.id == id.to_sym}
  end

  def self.categories
    all.sort_by{|s| s.category}.group_by{|s| s.category }
  end

  @@all_sources = nil
  def self.all
    @@all_sources ||= Source.load(YAML.load_file(File.join(Rails.root, "config", "sources.yml")))
  end

end