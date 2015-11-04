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
        info(address)
      else
        { 'address' => address, 'balance' => 0.0,
          'wallet_id' => '', 'wallet_knowns' => 0,
          'tx_count' => 0, 'tx' => nil }
      end
    end

    private

    def info(address)
      wallet_id = @wallet.id address

      {
        'address' => address,
        'balance' => @address[address],
        'wallet_id' => wallet_id,
        'wallet_size' => @wallet.count(wallet_id),
        'tx_count' => @tx_address.count(address),
        'tx' => @tx.fetch(@tx_address[address])
      }
    end
  end
end
