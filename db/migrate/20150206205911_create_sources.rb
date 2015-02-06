class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources, {id: false} do |t|
      t.string :id
      t.text :json
    end
  end
end
