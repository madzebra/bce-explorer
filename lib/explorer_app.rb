require 'sinatra/base'
require 'haml'
require 'bce-client'

module BceExplorer
  # Explorer app hosts coin
  class ExplorerApp < Sinatra::Base
    set :views, File.expand_path('views', Env.root)
    set :public_folder, File.expand_path('public', Env.root)
    set :haml, format: :html5, ugly: true

    helpers Route::Helpers
    helpers View::Helpers

    before do
      bcount = @cache.cache_for('block_count') { @client.block.count.to_s }
      @block_count = bcount.to_i
    end

    def initialize(coin = nil)
      fail if coin.nil?
      @db = coin.db
      @cache = coin.cache
      @client = coin.client
      @coin_info = coin.info
      super nil
    end

    get '/' do
      @blocks = (0...15).map do |n|
        @cache.cache_obj_for "block_#{@block_count - n}" do
          @client.block(@block_count - n).decode
        end
      end
      haml :index
    end

    get '/address/:address' do
      @address_info = nil
      if @client.address(params['address']).valid?
        @address_info = @cache.cache_obj_for "address_#{params['address']}" do
          @db.address.info params['address']
        end
      end
      haml :address
    end

    get '/block/:blk' do
      @block_info = @cache.cache_obj_for "block_with_tx_#{params['blk']}" do
        @client.block(params['blk']).decode_with_tx
      end
      haml :block
    end

    get '/tx/:txid' do
      @tx_info = @cache.cache_obj_for "tx_#{params['txid']}" do
        @client.transaction(params['txid']).decode
      end
      haml :tx
    end

    get '/wallet/:wallet_id' do
      # TODO: to cache this controller, it needs to be rewritten
      @wallet_balance = 0.0
      @wallet_knowns = @db.wallet.count params['wallet_id']
      @wallet_info = @db.wallet.info(params['wallet_id']).map do |a|
        @wallet_balance += a['balance']
        { 'address' => a['_id'], 'balance' => a['balance'] }
      end
      haml :wallet
    end

    get '/search' do
      if params['q'].is_a? String # in case of: /search?q[]=foo
        query = params['q'].strip
        if query.length > 0
          redirect to_tx(query) if @client.transaction(query).valid?
          redirect to_block(query) if @client.block(query).valid?
          redirect to_address(query) if @client.address(query).valid?
        end
      end
      haml :search_fail
    end

    get '/top20' do
      top 20
    end

    get '/top50' do
      top 50
    end

    get '/wallets' do
      @wallets = @db.wallet.top.map do |wallet|
        @cache.cache_obj_for "wallet_top_#{wallet['_id']}" do
          {
            id: wallet['_id'],
            name: @db.wallet.name(wallet['_id']),
            addresses: @db.wallet.count(wallet['_id']),
            balance: wallet['total'] }
        end
      end
      haml :wallets
    end

    get '/network' do
      @network_info = @cache.cache_obj_for 'network_info' do
        @client.network_info
      end
      @network_peer = @cache.cache_obj_for 'peer_info' do
        @client.network_peer_info
      end
      haml :network
    end

    get '/about' do
      haml :about
    end

    private

    def top(count)
      # TODO: this code returns mongo cursor, which can't be cached
      @top_list = @db.address.top count
      @top = count
      haml :richlist
    end
  end
end
