require 'securerandom'

module BceExplorer
  # Wallets clusters storage
  class Wallet
    def initialize(dbh)
      @wallets = dbh['wallets']
    end

    def merge(addresses)
      wallet = @wallets.find_one(_id: {'$in' => addresses})
      cluster_id = wallet.nil? ? SecureRandom.hex(8) : wallet['cluster_id']

      addresses.each do |address|
        new_wallet = {'_id' => address, 'cluster_id' => cluster_id}
        @wallets.insert(new_wallet) if @wallets.find_one(_id: address).nil?
      end
    end
  end
end
