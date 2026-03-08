class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.references :votable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end
    add_index :votes, [ :user_id, :votable_type, :votable_id ], unique: true
  end
end
