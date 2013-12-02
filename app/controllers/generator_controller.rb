class GeneratorController < ApplicationController

  def index
    parse_sources!
  end

  def generate
    head :ok and return if GENERATOR_DISABLED
    parse_sources!
  end

  def save
    head :ok and return if GENERATOR_DISABLED

    if Headline.salted_hash(params[:headline]) != params[:hash]
      head :forbidden
      return
    end

    @headline = Headline.where(name: params[:headline]).first_or_create
    @headline.sources = params[:sources].split(",")
    @headline.depth = params[:depth]
    @headline.save

    upvote_headline! @headline
  end

private

  def parse_sources!
    @sources = []
    Source.all.each do |source|
      @sources << source.id if params[source.id].to_i == 1
    end
    @sources = Source.all.reject{|s| !s.default }.map(&:id) if @sources.blank?
  end

end
