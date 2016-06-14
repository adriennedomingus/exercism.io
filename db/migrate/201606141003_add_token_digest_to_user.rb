class AddTokenDigestToUser < ActiveRecord::Migration
  def change
    add_column :users, :token_digest, :string
  end
end
