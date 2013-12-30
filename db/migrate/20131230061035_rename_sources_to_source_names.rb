class RenameSourcesToSourceNames < ActiveRecord::Migration
  def change
    rename_column :headlines, :sources, :source_names
  end
end
