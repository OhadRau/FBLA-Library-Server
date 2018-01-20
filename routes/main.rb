class LibraryApi
  get '/books/inStock' do
    Stock.where(status: "IN_STOCK").select(:title).distinct.to_json
  end

  get '/books/byIsbn/:isbn' do
    Stock.find_by(isbn: params[:isbn]).to_json
  end

  get '/user/:user/books' do
    Stock.where(user: params[:user]).to_json
  end

  get '/user/:user/reserved' do
    Stock.where(user: params[:user], status: "RESERVED").to_json
  end

  get '/user/:user/checked_out' do
    Stock.where(user: params[:user], status: "CHECKED_OUT").to_json
  end

  get '/user/:user/overdue' do
    Stock.where(user: params[:user], status: "CHECKED_OUT", due: [0, Date.today.to_s]).to_json
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
