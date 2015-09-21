module BceExplorer
  # address info report
  class WalletReport
    def initialize(db)
      @wallet = db.wallet
    end

    def call(wallet)
      balance = 0.0
      size = @wallet.count wallet
      info = @wallet.fetch(wallet).map do |address|
        balance += address['balance']
        { 'address' => address['_id'], 'balance' => address['balance'] }
      end
      { 'balance' => balance, 'size' => size, 'addresses' => info }
    end
  end
end
