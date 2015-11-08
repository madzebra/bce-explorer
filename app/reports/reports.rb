module BceExplorer
  # initialize reports
  class Reports
    attr_reader :address, :block

    def initialize(db)
      @address = AddressReport.new db
      @block = BlockReport.new db
    end
  end
end
