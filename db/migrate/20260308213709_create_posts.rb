class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :url
      t.text :body
      t.integer :points, default: 0, null: false
      t.string :post_type, default: "link", null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
