require_relative './address_report.rb'
require_relative './wallet_report.rb'

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
