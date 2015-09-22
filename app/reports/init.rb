module BceExplorer
  # initialize reports
  class Reports
    attr_reader :address, :wallet

    def initialize(db)
      @address = AddressReport.new db
      @wallet = WalletReport.new db
    end
  end
end
