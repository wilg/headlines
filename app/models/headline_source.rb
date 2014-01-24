class HeadlineSource < HeadlineSources::Source

  def headlines
    Headline.joins(:source_headlines).where("source_headlines.source_id = ?", self.id).uniq("headlines.id")
  end

end