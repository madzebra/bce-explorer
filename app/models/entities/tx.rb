module BceExplorer
  # Transaction entity
  module Entities
    Transaction = Struct.new :txid,
                             :version,
                             :time,
                             :blockindex,
                             :inputs,
                             :outputs do
      def self.create_from(params = {})
        new params['txid'], params['version'], params['time'],
            params['blockindex'],
            params['inputs'], params['outputs']
      end
    end
  end
end
