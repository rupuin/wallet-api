require 'rails_helper'

RSpec.describe Evm::ResourcesDto  do
  subject { described_class.new(methods, chains) }

  let(:methods) { { get_balance: 'eth_getBalance' } }
  let(:chains) { { blockchain: { mainnet: 'rpc-url' } } }

  it 'formats keys from symbols to strings' do
    expect(subject.chains.keys.first).to be_a(String)
  end

  describe '#to_h' do
    it 'returns a hash with methods and chains' do
      expect(subject.to_h).to eq({
          'methods' => ['get_balance'],
          'chains' => {
          'blockchain' => {
            'mainnet' => 'rpc-url'
          }
        }
      })
    end
  end

  describe '.from_constants' do
    subject { described_class.from_constants }

    context 'when initialized with constants' do
      before do
        stub_const('Evm::Constants::METHODS', methods)
        stub_const('Evm::Constants::CHAINS', chains)
      end

      it 'returns a dto with formatted attributes' do
        expect(subject.methods).to be_a(Array)
        expect(subject.chains.keys).to all(be_a(String))
      end
    end
  end
end
