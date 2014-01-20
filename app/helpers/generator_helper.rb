module GeneratorHelper

  def generator_sources
    rejected_ids = [:r_politics, :r_funny]
    HeadlineSources::Source.all.reject{|s| rejected_ids.include?(s.id) }.sort_by{|s| s.category}.group_by{|s| s.category }
  end

end
