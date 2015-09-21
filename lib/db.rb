require 'mongo'
require_relative '../app/models/base'
require_relative '../app/models/address'
require_relative '../app/models/info'
require_relative '../app/models/tx_address'
require_relative '../app/models/tx_list'
require_relative '../app/models/wallet'

module BceExplorer
  # db storage
  class DB
    include Mongo

    attr_reader :info, :address, :wallet, :tx_address, :tx_list

    def initialize(opts = nil)
      MongoClient.new(opts[:host], opts[:port]).db(opts[:dbname]).tap do |dbh|
        @info = Info.new dbh
        @wallet = Wallet.new dbh
        @tx_address = TxAddress.new dbh
        @tx_list = TxList.new dbh
        # this line MUST be the last, order is IMPORTANT
        @address = Address.new dbh
      end
    end
  end
end
