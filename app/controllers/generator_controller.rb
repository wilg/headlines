class GeneratorController < ApplicationController

  def index
    parse_sources!
  end

  def save
    head :ok and return if GENERATOR_DISABLED || GENERATOR_SAVING_DISABLED

    sources = JSON.parse(params[:sources_json])

    # if Headline.salted_hash(params[:headline]) != params[:hash]
    #   head :forbidden
    #   return
    # end

    @headline = Headline.with_name(params[:headline]).first_or_initialize

    if @headline.new_record?
      @headline.name = params[:headline]
      @headline.depth = params[:depth]
      @headline.creator = current_user
      @headline.save!
    end

    if @headline.new_record? || @headline.source_headline_fragments.size == 0
      @headline.create_sources!(sources)
    end

    current_user.upvote_headline! @headline

    @headline.reload
  end

private

  def parse_sources!
    @sources = []
    HeadlineSource.all.each do |source|
      @sources << source.id if params[source.id].to_i == 1
    end
    @sources = HeadlineSource.all.reject{|s| !s.default }.map(&:id) if @sources.blank?
  end

end
