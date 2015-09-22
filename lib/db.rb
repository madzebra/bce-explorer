module BceExplorer
  # db storage
  class DB
    include Mongo

    attr_reader :info, :address, :wallet, :tx_address, :tx_list

    def initialize(opts = nil)
      MongoClient.new(opts[:host], opts[:port]).db(opts[:dbname]).tap do |dbh|
        @info = Info.new dbh
        @address = Address.new dbh
        @wallet = Wallet.new dbh
        @tx_address = TxAddress.new dbh
        @tx_list = TxList.new dbh
      end
    end
  end
end
