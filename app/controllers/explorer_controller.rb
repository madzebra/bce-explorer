module BceExplorer
  # Explorer app hosts coin
  class ExplorerController < ApplicationController
    helpers ExplorerHelper

    set :layout_name, :explorer_layout

    before do
      @block_count = @db.info.blocks
      @money_supply = @db.info.money_supply
    end

    def initialize(coin = nil)
      fail if coin.nil?
      @db = coin.db
      @coin_info = coin.info
      @reports = Reports.new @db
      super
    end

    get '/' do
      @blocks = @db.block.last
      render_with :index
    end

    get '/address/:address' do
      @address_info = nil
      if Base58.valid? params['address']
        @address_info = @reports.address.call params['address']
      end
      render_with :address
    end

    get '/block/:blk' do
      @block_info = @reports.block.call params['blk']
      render_with :block
    end

    get '/tx/:txid' do
      @tx_info = @db.tx[params['txid']]
      render_with :tx
    end

    get '/wallet/:wallet_id' do
      @wallet_info = nil
      if @db.wallet.exists? params['wallet_id']
        @wallet_info = @db.wallet.fetch params['wallet_id']
      end
      render_with :wallet
    end

    get '/search' do
      if params['q'].is_a? String # in case of: /search?q[]=foo
        query = params['q'].strip
        if query.length > 0
          redirect to_tx(query) if @db.tx.valid?(query)
          redirect to_block(query) if @db.block.valid?(query)
          redirect to_address(query) if Base58.valid?(query)
        end
      end
      render_with :search_fail
    end

    get '/wallets' do
      @wallets = @db.wallet.top
      render_with :wallets
    end

    get '/network' do
      @network_info = @db.info.network
      @network_peer = @db.info.peers
      render_with :network
    end

    get '/top100' do
      top 100
    end

    get '/top250' do
      top 250
    end

    get '/about' do
      render_with :about
    end

    get '*' do
      not_found
    end

    private

    def top(count)
      @top = count
      @top_list = @db.richlist.top(count)
      render_with :richlist
    end
  end
end
