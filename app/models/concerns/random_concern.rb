module RandomConcern
  extend ActiveSupport::Concern

  included do
    scope :random_set, -> (approximate_limit: nil, percent: nil) {
      if approximate_limit
        num = count
        raise "Limit must be <= #{num}" if num < approximate_limit
        from("#{table_name} TABLESAMPLE SYSTEM(#{approximate_limit.to_f / num.to_f * 100})")
      elsif percent
        from("#{table_name} TABLESAMPLE SYSTEM(#{percent.to_f})")
      else
        raise "Must pass approximate_limit or percent"
      end
    }
  end

end
