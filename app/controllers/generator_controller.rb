class GeneratorController < ApplicationController

  def index
    parse_sources!
  end

  def generate
    head :ok and return if GENERATOR_DISABLED
    parse_sources!
  end

  def save
    head :ok and return if GENERATOR_DISABLED || GENERATOR_SAVING_DISABLED

    if Headline.salted_hash(params[:headline]) != params[:hash]
      head :forbidden
      return
    end

    @headline = Headline.where(name: params[:headline]).first_or_initialize
    if @headline.new_record?
      @headline.sources = params[:sources].split(",")
      @headline.depth = params[:depth]
      @headline.creator = current_user
      @headline.save!
    end

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
