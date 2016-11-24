class HeadlineSource < HeadlineSources::Source

  def headlines
    Headline.joins(:source_headlines).where("source_headlines.source_id = ?", self.id).uniq("headlines.id")
  end

  def source_headlines
    SourceHeadline.where(source_id: self.id.to_s)
  end

  def votes
    Vote.joins(headline: :source_headlines).where("source_headlines.source_id = ?", self.id)
  end

  def fake?
    fake_source.present?
  end

end
