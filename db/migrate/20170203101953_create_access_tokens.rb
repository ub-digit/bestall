class CreateAccessTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :access_tokens do |t|
      t.integer :user_id
      t.text :token
      t.datetime :token_expire
      t.text :username
    end
  end
end
