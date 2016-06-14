class CreateAuthTokens < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.string     :selector
      t.datetime   :expiration
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
