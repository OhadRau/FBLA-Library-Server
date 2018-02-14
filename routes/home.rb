class LibraryApi
  get '/' do
    content_type :html
    locals = {
      books: union(Stock.joins(:book)
                         .where(status: "IN_STOCK")
                         .select(:isbn, :dewey, :title, :author, :publisher, :edition, :copyright, :cover, 'COUNT(stock.isbn) AS left').group(:isbn),
                    Book.all
                        .select("*", '0 AS left'),
                    by: :isbn),
    }

    slim :home, locals: locals
  end
end
