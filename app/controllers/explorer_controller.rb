module BceExplorer
  # Explorer app hosts coin
  class ExplorerController < ApplicationController
    helpers ExplorerHelper

    before do
      @block_count = @db.info.blocks
      @money_supply = @db.info.money_supply
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
      @address_info = nil
      if @client.address(params['address']).valid?
        @address_info = @reports.address.call params['address']
      end
      haml :address
    end

    get '/block/:blk' do
      @block_info = @reports.block.call params['blk']
      haml :block
    end

    get '/tx/:txid' do
      @tx_info = @db.tx[params['txid']]
      haml :tx
    end

    get '/wallet/:wallet_id' do
      @wallet_info = nil
      if @db.wallet.exists? params['wallet_id']
        @wallet_info = @reports.wallet.call params['wallet_id']
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

    get '/wallets' do
      @wallets = @db.wallet.top
      haml :wallets
    end

    get '/network' do
      @network_info = @db.info.network
      @network_peer = @db.info.peers
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
