require 'securerandom'

module BceExplorer
  # Wallets clusters storage
  class Wallet
    def initialize(dbh)
      @addr_db = dbh['addresses']
      @wallets = dbh['wallets']
    end

    def merge(addresses)
      wallet = @wallets.find_one _id: { '$in' => addresses }
      cluster_id = wallet.nil? ? SecureRandom.hex(8) : wallet['cluster_id']

      addresses.each do |address|
        new_wallet = { '_id' => address, 'cluster_id' => cluster_id }
        @wallets.insert(new_wallet) if find_one(address).nil?
      end
    end

    def info(cluster_id)
      addresses = @wallets.find({ cluster_id: cluster_id })
      return nil if addresses.nil?
      find_all addresses.map { |a| a['_id'] }
    end

    def known(cluster_id)
      @wallets.count query: { cluster_id: cluster_id }
    end

    private

    def find_one(address)
      @wallets.find_one _id: address
    end

    def find_all(addresses = [], count = 100)
      @addr_db
        .find({ _id: { '$in' => addresses }, balance: { '$gt' => 1e-8 } })
        .sort(balance: :desc)
        .limit count
    end
  end
end
