module BceExplorer
  # db storage
  class DB
    include Mongo

    attr_reader :info, :address, :block, :wallet, :richlist, :tx_address, :tx

    def initialize(opts = nil)
      MongoClient.new(opts[:host], opts[:port]).db(opts[:dbname]).tap do |dbh|
        @info = Info.new dbh
        @address = Address.new dbh
        @block = Block.new dbh
        @wallet = Wallet.new dbh
        @richlist = Richlist.new dbh
        @tx_address = TxAddress.new dbh
        @tx = Transaction.new dbh
      end
    end
  end
end
