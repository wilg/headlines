class AddPhotoDataToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :photo_data, :text
  end
end
