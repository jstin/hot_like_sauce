ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, :force => true do |t|
    t.string :title
    t.text :body
    t.timestamps
  end

  create_table :grapes, :force => true do |t|
    t.integer :vineyard_id
    t.string :title
    t.text :contents
    t.timestamps
  end

end