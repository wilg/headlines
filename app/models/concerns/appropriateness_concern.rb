module AppropriatenessConcern
  extend ActiveSupport::Concern

  included do
    scope :appropriate, -> {
      out = where({})
      DISALLOWED_WORDS.each do |word|
        out = out.where.not("name_hash LIKE :word", word: "%#{word}%")
      end
      out
    }
    scope :inappropriate, -> {
      out = where({})
      snippets = []
      values = []
      DISALLOWED_WORDS.each do |word|
        snippets << "name_hash LIKE (?)"
        values << "%#{word}%"
      end
      where("(#{snippets.join(" OR ")})", *values)
    }
  end
end
