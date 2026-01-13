require 'rails_helper'

RSpec.describe Blockchain::Evm::Endpoint do
  describe '.for' do
    subject { described_class.for(chain, testnet) }

    let(:chain) { :blockchain }
    let(:testnet) { false }
    let(:api_key) { 'secret' }

    before do
      allow(ENV).to receive(:fetch).with('INFURA_API_KEY').and_return(api_key)
      stub_const('Evm::Constants::CHAINS', { blockchain: { testnet: 'https://testnet-rpc/', mainnet: 'https://mainnet-rpc/' } })
    end

    context 'when chain is found' do
      context 'and testnet is false' do
        it 'returns mainnet rpc with api key appended' do
          expect(subject).to eq('https://mainnet-rpc/secret')
        end
      end

      context 'and testnet is true' do
        let(:testnet) { true }

        it 'returns testnet rpc with api key appended' do
          expect(subject).to eq('https://testnet-rpc/secret')
        end
      end
    end

    context 'when chain is not found' do
      let(:chain) { :unsupported }

      it 'raises and error' do
        expect { subject }.to raise_error(ArgumentError, "unsupported chain: #{chain}")
      end
    end
  end
end
