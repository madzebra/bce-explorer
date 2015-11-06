module BceExplorer
  # db storage
  class DB
    include Mongo

    attr_reader :info, :address, :block, :wallet, :richlist, :tx_address, :tx

    def initialize(opts = nil)
      @dbh = MongoClient.new(opts[:host], opts[:port]).db(opts[:dbname])
      @info = Info.new @dbh
      @address = Address.new @dbh
      @block = Block.new @dbh
      @wallet = Wallet.new @dbh
      @richlist = Richlist.new @dbh
      @tx_address = TxAddress.new @dbh
      @tx = Transaction.new @dbh
    end

    def create_index
      @dbh['address'].create_index 'balance'
      @dbh['address'].create_index 'wallet'
      @dbh['block'].create_index 'hash'
      @dbh['tx_address'].create_index 'address'
      @dbh['tx_address'].create_index 'txid'
    end
  end
end
