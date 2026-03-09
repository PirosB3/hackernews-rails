class CreatePasskeyCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :passkey_credentials do |t|
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.string :nickname
      t.integer :sign_count, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :passkey_credentials, :external_id, unique: true
  end
end
