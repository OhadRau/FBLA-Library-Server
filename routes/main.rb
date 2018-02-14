require_relative 'home'
class LibraryApi
  get '/books' do
    {books: Book.all}.to_json
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
    {stock: Stock.select("*", "date('now') > due AS overdue").joins(:book).where(user: params[:user])}.to_json
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

  post '/book/add' do
    book = Book.create({
      isbn: params[:isbn],
      dewey: params[:dewey],
      title: params[:title],
      author: params[:author],
      publisher: params[:publisher],
      edition: params[:edition],
      copyright: params[:copyright]
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

end
