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
        @address_info = fetch_address_info params['address']
      end
      haml :address
    end

    get '/block/:blk' do
      @block_info = fetch_block_info params['blk']
      haml :block
    end

    get '/tx/:txid' do
      @tx_info = fetch_tx_info params['txid']
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
      @network_info = fetch_network_info
      @network_peer = fetch_peer_info
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

    def fetch_address_info(address)
      @cache.cache_obj_for "address_#{address}" do
        @db.address.info address
      end
    end

    def fetch_block_info(block)
      @cache.cache_obj_for "block_with_tx_#{block}" do
        @client.block(block).decode_with_tx
      end
    end
    def fetch_tx_info(txid)
      @cache.cache_obj_for "tx_#{txid}" do
        @client.transaction(txid).decode
      end
    end

    def fetch_network_info
      @cache.cache_obj_for 'network_info' do
        @client.network_info
      end
    end

    def fetch_peer_info
      @cache.cache_obj_for 'peer_info' do
        @client.network_peer_info
      end
    end
  end
end
