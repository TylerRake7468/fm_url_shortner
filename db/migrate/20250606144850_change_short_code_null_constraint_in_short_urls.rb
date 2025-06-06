class ChangeShortCodeNullConstraintInShortUrls < ActiveRecord::Migration[7.1]
  def change
    change_column_null :short_urls, :short_code, true
  end
end
