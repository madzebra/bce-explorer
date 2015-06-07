require 'securerandom'

module BceExplorer
  # Wallets clusters storage
  class Wallet
    def initialize(dbh)
      @wallets = dbh['wallets']
    end

    def merge(addresses)
      cluster = @wallets.find_one('_id' => {'$in' => addresses})
      cluster_id = cluster.nil? ? SecureRandom.hex(8) : cluster['_id']

      addresses.each do |address|
        wallet = {'_id' => address, 'cluster_id' => cluster_id}
        @wallets.insert(wallet) if @wallets.find_one(wallet).nil?
      end
    end
  end
end
