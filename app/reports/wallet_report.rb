module BceExplorer
  # address info report
  class WalletReport
    def initialize(db)
      @wallet = db.wallet
    end

    def call(wallet)
      @wallet.fetch wallet
    end
  end
end
