require 'mongo'
require_relative './models/base'
require_relative './models/address'
require_relative './models/info'
require_relative './models/tx_address'
require_relative './models/tx_list'
require_relative './models/wallet'

module BceExplorer
  # db storage
  class DB
    include Mongo

    attr_reader :info, :address, :tx_address, :tx_list, :wallet

    def initialize(options = {})
      host = options[:host] || 'localhost'
      port = options[:port] || 27_017
      dbname = options[:dbname] || 'blockexplorer'

      MongoClient.new(host, port).db(dbname).tap do |dbh|
        @info = Info.new dbh
        @address = Address.new dbh
        # TODO: look into this
        @tx_address = TxAddress.new dbh
        @tx_list = TxList.new dbh
        @wallet = Wallet.new dbh
      end
    end
  end
end
