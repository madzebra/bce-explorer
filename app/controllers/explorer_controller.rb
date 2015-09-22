module BceExplorer
  # Explorer app hosts coin
  class ExplorerController < ApplicationController
    helpers ExplorerHelper

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
      @reports = Reports.new @db
      super
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
      if @client.address(params['address']).valid?
        @address_info = @cache.cache_obj_for "address_#{params['address']}" do
          @reports.address.call params['address']
        end
      end
      @address_info ||= {}
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
      if @db.wallet.exists? params['wallet_id']
        @wallet_info = @cache.cache_obj_for "wallet_#{params['wallet_id']}" do
          @reports.wallet.call params['wallet_id']
        end
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
        @cache.cache_obj_for "wallet_top_#{wallet['_id']}" do
          {
            'id' => wallet['_id'],
            'name' => @db.wallet.name(wallet['_id']),
            'size' => @db.wallet.count(wallet['_id']),
            'balance' => wallet['total']
          }
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
      @top_list = @db.address.top(count).map do |address|
        @cache.cache_obj_for "richlist_#{address['_id']}" do
          { 'address' => address['_id'], 'balance' => address['balance'] }
        end
      end
      haml :richlist
    end
  end
end
