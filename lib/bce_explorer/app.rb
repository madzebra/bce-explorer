require 'sinatra/base'
require 'haml'
require 'bce-client'

module BceExplorer
  # Application class for app
  class App < Sinatra::Base
    set :views, File.expand_path('../../views', File.dirname(__FILE__))
    set :public_folder, File.expand_path('public', Env.root)
    set :haml, format: :html5, ugly: true

    helpers Route::Helpers
    helpers View::Helpers

    before do
      @block_count = @client.block.count
    end

    def initialize(coin = nil, internal_sync_rich_list = false)
      fail if coin.nil?
      @db = DB.new coin.db_options
      @client = BceClient::Client.new coin.client_options
      @coin_info = coin.info
      sync_rich_list if internal_sync_rich_list
      super nil
    end

    get '/address/:address' do
      @address_info = nil
      if @client.address(params['address']).valid?
        @address_info = @db.address.info params['address']
      end
      haml :address
    end

    get '/block/:blk' do
      @block_info = @client.block(params['blk']).decode_with_tx
      haml :block
    end

    get '/tx/:txid' do
      @tx_info = @client.transaction(params['txid']).decode
      haml :tx
    end

    get '/wallet/:wallet_id' do
      @wallet_balance = 0.0
      @wallet_knowns = @db.wallet.count params['wallet_id']
      @wallet_info = @db.wallet.info(params['wallet_id']).map do |a|
        @wallet_balance += a['balance']
        { address: a['_id'], balance: a['balance'] }
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
        {
          id: wallet['_id'],
          name: @db.wallet.name(wallet['_id']),
          addresses: @db.wallet.count(wallet['_id']),
          balance: wallet['total'] }
      end
      haml :wallets
    end

    get '/network' do
      @network_info = @client.network_info
      @network_peer = @client.network_peer_info
      haml :network
    end

    get '/about' do
      haml :about
    end

    get '/' do
      @blocks = (0...15).map { |n| @client.block(@block_count - n).decode }
      haml :index
    end

    private

    def top(count)
      @top_list = @db.address.top count
      @top = count
      haml :richlist
    end

    def rich_list
      RichList.new blockexplorer: @client, database: @db
    end

    def sync_rich_list
      Thread.new do
        loop do
          sleep 60
          rich_list.sync!
        end
      end
    end
  end
end
