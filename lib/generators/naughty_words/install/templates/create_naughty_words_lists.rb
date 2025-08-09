# frozen_string_literal: true

class CreateNaughtyWordsLists < ActiveRecord::Migration[7.0]
  def change
    create_table :naughty_words_lists do |t|
      t.string :word, null: false
      t.string :list_type, null: false # 'deny' or 'allow'
      t.string :category
      t.string :severity               # "high" | "medium" | "low"
      t.text   :context
      t.string :added_by
      t.json   :metadata, default: {}
      t.timestamps

      t.index [:word, :list_type], unique: true
      t.index :category
      t.index :severity
    end
  end
end 
