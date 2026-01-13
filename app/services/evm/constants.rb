class Evm::Constants
  METHODS = {
    get_balance: 'eth_getBalance',
    get_transaction_count: 'eth_getTransactionCount',
    block_number: 'eth_blockNumber',
    get_block_by_number: 'eth_getBlockByNumber'
  }.freeze

  CHAINS = {
    ethereum: {
      mainnet: 'https://mainnet.infura.io/v3/',
      testnet: 'https://sepolia.infura.io/v3/'
    },
    base: {
      mainnet: 'https://base-mainnet.infura.io/v3/',
      testnet: 'https://base-sepolia.infura.io/v3/'
    },
    linea: {
      mainnet: 'https://linea-mainnet.infura.io/v3/',
      testnet: 'https://linea-sepolia.infura.io/v3/'
    },
    polygon: {
      mainnet: 'https://polygon-mainnet.infura.io/v3/',
      testnet: 'https://polygon-amoy.infura.io/v3/'
    }
  }.freeze

  BLOCK_TAGS = ['latest', 'earliest', 'pending', 'safe', 'finalized'].freeze
end
