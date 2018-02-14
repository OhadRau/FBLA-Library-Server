class Stock < ActiveRecord::Base
  self.pluralize_table_names = false
  self.primary_key = "ROWID"
  belongs_to :book, foreign_key: 'isbn'

  def self.check_out(isbn, user)
    slot = Stock.find_by(isbn: isbn, status: "IN_STOCK")
    unless slot.nil?
      slot.status = "CHECKED_OUT"
      slot.since = Date.today.to_s
      slot.due = (Date.today + $CONFIG[:checkout_days].days).to_s
      slot.user = user
      slot.save!
    end
  end

  def self.reserve(isbn, user)
    book = Book.where(isbn: isbn).first
    if book.reserved_by.nil?
      reserved_by = [user].to_json
      book.reserved_by = reserved_by
      book.save!
    else
      reserved_by = JSON.parse(book.reserved_by)
      reserved_by << user
      book.reserved_by = reserved_by.to_json
      book.save!
    end
  end

  def self.check_in(isbn, user)
    slot = Stock.find_by(isbn: isbn, user: user)
    book = Book.where(isbn: isbn).first
    if book.reserved_by.nil?
      unless slot.nil?
        slot.status = "IN_STOCK"
        slot.since = nil
        slot.due = nil
        slot.user = nil
        slot.save!
      end
    else
      unless slot.nil?
        reserved_by = JSON.parse(book.reserved_by)
        slot.status = "CHECKED_OUT"
        slot.since = Date.today.to_s
        slot.due = (Date.today + $CONFIG[:checkout_days].days).to_s
        slot.user = reserved_by[0]
        slot.save!
        reserved_by.shift
        book.reserved_by = reserved_by.to_json
        book.save!
      end
    end
  end
end
