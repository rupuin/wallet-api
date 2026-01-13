class Blockchain::Evm::Endpoint
  def self.for(chain, testnet)
    resolve(chain, testnet)
  end

  private

  def self.api_key
    @api_key ||= ENV.fetch('INFURA_API_KEY')
  end

  def self.resolve(chain, testnet)
    chain_data = Evm::Constants::CHAINS[chain.to_sym] || raise(ArgumentError, "unsupported chain: #{chain}")
    base_url = testnet ? chain_data[:testnet] : chain_data[:mainnet]

    "#{base_url}#{api_key}"
  end
end
