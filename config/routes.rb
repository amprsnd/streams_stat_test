Rails.application.routes.draw do

  scope 'stats' do
    post 'watch',         to: 'stats#watch',    as: 'watch'
    get  'customer/:id',  to: 'stats#customer', as: 'customer'
    get  'stream/:id',    to: 'stats#stream',   as: 'stream'
  end

end
