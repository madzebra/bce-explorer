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
        new params['_id'],
            (params['sent'] || 0.0),
            (params['received'] || 0.0),
            (params['balance'] || 0.0),
            params['wallet'], params['txs']
      end
    end
  end
end
