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

    attr_reader :info, :address, :wallet, :tx_address, :tx_list

    def initialize(options = {})
      host = options[:host] || 'localhost'
      port = options[:port] || 27_017
      dbname = options[:dbname] || 'blockexplorer'

      MongoClient.new(host, port).db(dbname).tap do |dbh|
        @info = Info.new dbh
        @wallet = Wallet.new dbh
        @tx_address = TxAddress.new dbh
        @tx_list = TxList.new dbh
        # this line MUST be the last, order is IMPORTANT
        @address = Address.new dbh, self
      end
    end
  end
end
