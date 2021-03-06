require_relative 'home'
class LibraryApi
  get '/books' do
    {books: Book.all
                .left_outer_joins(:stock)
                .select("*")
                .select("COUNT (CASE WHEN stock.status = 'IN_STOCK' THEN stock.status END) AS left")
                .group(:isbn)}.to_json
  end

  get '/user/:user/has/:isbn' do
    if Stock.where(isbn: params[:isbn]).where(user: params[:user]).exists?
      return {user: params[:user] ,isbn: params[:isbn], has: true}.to_json
    else
      return {user: params[:user] ,isbn: params[:isbn], has: false}.to_json
    end
  end

  get '/books/stock' do
    {stock: union(Stock.joins(:book)
                       .where(status: "IN_STOCK")
                       .select(:isbn, :dewey, :title, :author, :publisher, :edition, :copyright, :cover, 'COUNT(stock.isbn) AS left')
                       .group(:isbn),
                  Book.all
                      .select("*", "0 AS left"),
                  by: :isbn)
    }.to_json
  end

  get '/books/search/:query' do
    query = params[:query]
    {books: Book.where("title LIKE ? OR author LIKE ? OR books.isbn LIKE ?", 
                       "%#{query}%", "%#{query}%", "%#{query}%")
                       .left_outer_joins(:stock)
                       .select("*")
                       .select("COUNT (CASE WHEN stock.status = 'IN_STOCK' THEN stock.status END) AS left")
                       .group(:isbn)}.to_json

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

  get '/books/byDewey/:range' do 
    range = params[:range]
    {books: Book
          .where("dewey LIKE ?", "#{range}%")
          .left_outer_joins(:stock)
          .select("*")
          .select("COUNT (CASE WHEN stock.status = 'IN_STOCK' THEN stock.status END) AS left")
          .group(:isbn)}.to_json
  end

  get '/user/:user/books' do
    {stock: Stock.select("*", "date('now') > due AS overdue").joins(:book).where(user: params[:user])}.to_json
  end

  get '/user/:user/reserved' do
    {reserved: Stock.where(user: params[:user], status: "RESERVED")}.to_json
  end

  get '/user/:user/checked_out' do
    {checked_out: Book.all
                      .left_outer_joins(:stock)
                      .where(stock: {user: params[:user], status: "CHECKED_OUT"})
                      .select("*")
                      .select("COUNT (CASE WHEN stock.status = 'IN_STOCK' THEN stock.status END) AS left")
                      .group(:isbn)}.to_json
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

  post '/book/add' do
    book = Book.create({
      isbn: params[:isbn],
      dewey: params[:dewey],
      title: params[:title],
      author: params[:author],
      publisher: params[:publisher],
      edition: params[:edition],
      copyright: params[:copyright],
      reserved_by: [].to_json
      })
    unless params[:cover].nil?
      File.open("./public/img/#{params[:isbn]}", 'wb') do |f|
        f.write(params[:cover][:tempfile].read)
      end
    end
    redirect '/'
  end

  post '/book/:isbn/addStock' do
    Stock.create({
      isbn: params[:isbn],
      status: "IN_STOCK"
    })
  end

  post '/report/:user/submit' do
    message = params[:message]
    user = params[:user]
    pp params

    Report.create({
      message: message,
      user: user
    })
  end

  post '/report/:id/dismiss' do
    id = params[:id]
    Report.where(ROWID: id).destroy_all
    return nil  
  end

end
