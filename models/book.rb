class Book < ActiveRecord::Base
  has_many :stock, foreign_key: 'isbn'
end
