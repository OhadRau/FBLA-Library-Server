class LibraryApi
  get '/books' do
    {books: Book.all}.to_json
  end

  get '/books/stock' do
    {stock: Stock.all
                 .joins(:book)
                 .select("*", 'COUNT(stock.isbn) AS left')}.to_json
  end

  get '/books/inStock' do
    {books: Stock.joins(:book)
                 .where(status: "IN_STOCK")
                 .select(:isbn, :dewey, :title, :author, :publisher, :edition, :copyright, :cover, 'COUNT(stock.isbn) AS left').group(:isbn)
    }.to_json
  end

  get '/books/byIsbn/:isbn' do
    Book.find_by(isbn: params[:isbn]).to_json
  end

  get '/user/:user/books' do
    {stock: Stock.select("*").joins(:book).where(user: params[:user])}.to_json
  end

  get '/user/:user/reserved' do
    {reserved: Stock.where(user: params[:user], status: "RESERVED")}.to_json
  end

  get '/user/:user/checked_out' do
    {checked_out: Stock.where(user: params[:user], status: "CHECKED_OUT")}.to_json
  end

  get '/user/:user/overdue' do
    {overdue: Stock.where(user: params[:user], status: "CHECKED_OUT", due: [0, Date.today.to_s])}.to_json
  end

  post '/books/byIsbn/:isbn/checkOutFor/:user' do
    Stock.check_out(params[:isbn], params[:user])
  end

  post '/books/byIsbn/:isbn/reserveFor/:user' do
    Stock.reserve(params[:isbn], params[:user])
  end

  post '/books/byIsbn/:isbn/checkInFor/:user' do
    Stock.check_in(params[:isbn], params[:user])
  end
end
