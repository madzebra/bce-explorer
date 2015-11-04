module BceExplorer
  # address info report
  class AddressReport
    def initialize(db)
      @address = db.address
      @wallet = db.wallet
      @tx_address = db.tx_address
      @tx = db.tx
    end

    def call(address)
      if @address.exists? address
        info_about address
      else
        params = { 'address' => address, 'wallet' => '',
                   'wallet_size' => 0, 'tx_count' => 0, 'tx' => [] }
        Entities::Address.create_from params
      end
    end

    private

    def info_about(address)
      wallet_id = @wallet.id address
      address_info = @address.fetch address
      address_info['wallet_size'] = @wallet.count wallet_id
      address_info['tx_count'] = @tx_address.count address
      address_info['tx'] = @tx.fetch @tx_address[address]
      address_info
    end
  end
end
