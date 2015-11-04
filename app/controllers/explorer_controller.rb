module BceExplorer
  # Explorer app hosts coin
  class ExplorerController < ApplicationController
    helpers ExplorerHelper

    before do
      @block_count = @db.info.blocks
    end

    def initialize(coin = nil)
      fail if coin.nil?
      @db = coin.db
      @client = coin.client
      @coin_info = coin.info
      @reports = Reports.new @db
      super
    end

    get '/' do
      @blocks = @db.block.last
      haml :index
    end

    get '/address/:address' do
      if @client.address(params['address']).valid?
        @address_info = @reports.address.call params['address']
      end
      @address_info ||= {}
      haml :address
    end

    get '/block/:blk' do
      @block_info = @db.block[params['blk']]
      haml :block
    end

    get '/tx/:txid' do
      @tx_info = @db.transaction[params['txid']]
      haml :tx
    end

    get '/wallet/:wallet_id' do
      if @db.wallet.exists? params['wallet_id']
        @wallet_info = @reports.wallet.call params['wallet_id']
      end
      @wallet_info ||= {}
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

    get '/wallets' do
      @wallets = @db.wallet.top.map do |wallet|
        {
          'id' => wallet['_id'],
          'name' => @db.wallet.name(wallet['_id']),
          'size' => @db.wallet.count(wallet['_id']),
          'balance' => wallet['total']
        }
      end
      haml :wallets
    end

    get '/network' do
      @network_info = @client.network_info
      @network_peer = @client.network_peer_info
      haml :network
    end

    get '/top20' do
      top 20
    end

    get '/top50' do
      top 50
    end

    get '/about' do
      haml :about
    end

    private

    def top(count)
      @top = count
      @top_list = @db.richlist.top(count)
      haml :richlist
    end
  end
end
