class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources, {id: false} do |t|
      t.string :id
      t.json :json
    end
  end
end
