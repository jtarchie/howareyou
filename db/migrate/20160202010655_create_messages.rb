class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :incoming_message
      t.string :outgoing_message
      t.string :from_number
      t.string :to_number
      t.timestamps null: false
    end
  end
end
