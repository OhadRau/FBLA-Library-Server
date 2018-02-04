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
    slot = Stock.find_by(isbn: isbn, status: "IN_STOCK")
    unless slot.nil?
      slot.status = "RESERVED"
      slot.since = Date.today.to_s
      slot.due = nil
      slot.user = user
      slot.save!
    end
  end

  def self.check_in(isbn, user)
    slot = Stock.find_by(isbn: isbn, user: user)
    unless slot.nil?
      slot.status = "IN_STOCK"
      slot.since = nil
      slot.due = nil
      slot.user = nil
      slot.save!
    end
  end
end
