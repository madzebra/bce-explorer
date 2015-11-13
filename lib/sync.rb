module BceExplorer
  # sync db routines
  class Sync
    def initialize(blockexplorer:, database:)
      @be = blockexplorer
      @db = database
    end

    def sync_db
      blocks = sync_info
      prev_block = @be.block(blocks - 1).decode
      @db.block.update(prev_block) if blocks > 1
      (blocks..@db.info.blocks).each do |blk_num|
        sync_block @be.block(blk_num).decode
      end
    end

    private

    def sync_info
      info = @db.info
      blocks = info.blocks
      info.network = @be.network_info
      info.peers = @be.network_peer_info
      blocks + 1
    end

    def sync_block(block)
      @db.block << block
      block['tx'].each_with_index do |tx, index|
        tx['type'] = calc_tx_type block, index
        sync_transaction tx, block['height']
      end
    end

    def sync_transaction(tx, blk_num)
      tx['blockindex'] = blk_num
      sync_inputs tx
      sync_outputs tx
      sync_wallets tx
      @db.tx << tx
    end

    def sync_inputs(tx)
      tx['inputs'].each do |input|
        address = input['address']
        next if generation? address
        type = (tx['type'] == 'minted') ? 'minted' : 'in'
        @db.address.sub address, input['value'].to_f, (type == 'minted')
        @db.tx_address << { address: address, txid: tx['txid'], type: type }
      end
    end

    def sync_outputs(tx)
      tx['outputs'].each do |output|
        address = output['address']
        next if stake? address
        type = (tx['type'] == 'minted') ? 'minted' : 'out'
        @db.address.add address, output['value'].to_f, (type == 'minted')
        @db.tx_address << { address: address, txid: tx['txid'], type: type }
      end
    end

    def sync_wallets(tx)
      wallets = @db.wallet
      wallets.merge extract_addresses_from(tx['inputs'])

      extract_addresses_from(tx['outputs'])
        .each { |address| wallets.merge address }
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

    def calc_tx_type(block, index)
      if ((block['flags'].include? 'stake') && (index < 2)) || (index < 1)
        'minted'
      else
        'out'
      end
    end
  end
end
