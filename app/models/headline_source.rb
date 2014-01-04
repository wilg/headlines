class HeadlineSource < HeadlineSources::Source

  def headlines
    Headline.includes(:source_headlines).where("source_headlines.source_id = ?", self.id)
  end

end