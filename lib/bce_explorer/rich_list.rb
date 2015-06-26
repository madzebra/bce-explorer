module BceExplorer
  # richlist sync routine
  class RichList
    def initialize(options = {})
      @be = options[:blockexplorer]
      @db = options[:database]
      fail if @be.nil? || @db.nil?
    end

    def sync!
      ((@db.info.blocks + 1)..@be.block.count).each do |blk_num|
        @be.block(blk_num).decode_with_tx['tx'].each do |tx|
          sync_addresses tx
          @db.transaction << tx
        end
        @db.info.blocks = blk_num
      end
    end

    private

    def sync_addresses(tx)
      sync_wallets tx
      sync_inputs tx
      sync_outputs tx
    end

    def sync_inputs(tx)
      tx['inputs'].each do |input|
        address = input['address']
        next if generation? address
        @db.address[address] -= input['value'].to_f
        @db.tx_address << { address: address, txid: tx['txid'] }
      end
    end

    def sync_outputs(tx)
      tx['outputs'].each do |output|
        address = output['address']
        next if stake? address
        @db.address[address] += output['value'].to_f
        @db.tx_address << { address: address, txid: output['txid'] }
      end
    end

    def sync_wallets(tx)
      addresses = extract_addresses_from tx['inputs']
      @db.wallet.merge! addresses

      extract_addresses_from(tx['outputs'])
        .each { @db.wallet.merge! address }
    end

    def extract_addresses_from(source)
      source
        .map { |row| row['address'] }
        .reject { |address| generation?(address) || stake?(address) }
    end

    def stake?(address)
      address == 'stake'
    end

    def generation?(address)
      address.include? 'Generation'
    end
  end
end
