module BceExplorer
  # Transaction entity
  module Entities
    Transaction = Struct.new :txid,
                             :version,
                             :time,
                             :blockhash,
                             :confirmations,
                             :vin,
                             :vout do
      def self.create_from(params = {})
        new params['txid'], params['version'], params['time'],
            params['blockhash'], params['confirmations'],
            params['vin'], params['vout']
      end
    end
  end
end
