module BceExplorer
  # Address entity
  module Entities
    Address = Struct.new :address,
                         :sent,
                         :received,
                         :balance,
                         :wallet,
                         :txs do
      def self.create_from(params = {})
        new params['address'], params['sent'], params['received'],
            params['balance'], params['wallet'], params['txs']
      end
    end
  end
end
