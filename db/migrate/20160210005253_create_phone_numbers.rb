class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.string :number
    end

    add_index :phone_numbers, :number, unique: true
  end
end
