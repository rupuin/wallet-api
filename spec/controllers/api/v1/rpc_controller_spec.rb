require 'rails_helper'

RSpec.describe Api::V1::RpcController, type: :controller  do
  describe 'GET #resources' do
    it 'calls Evm:ResourcesDto and returns 200' do
      expect(Evm::ResourcesDto).to receive(:from_constants)
      get :resources
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #call' do
    let(:dto) do
      instance_double(
        Evm::RpcDto,
        valid?: true,
        chain: 'ethereum',
        testnet: false,
        method: :get_balance,
        address: '0x0000000000000000000000000000000000000000',
        block_tag: 'latest',
        block_number: nil,
        full_transaction: true
      )
    end

    let(:request_params) do
      {
        'dashboard' => {
          'chain' => 'blockchain',
          'testnet' => 'false',
          'address' => '0x0000000000000000000000000000000000000000',
          'method' => 'get_balance',
          'block_tag' => 'latest',
          'block_number' => '',
          'full_transaction' => 'true'
        }
      }
    end

    let(:rpc_params) { request_params['dashboard'].symbolize_keys }

    before  do
      allow(Evm::RpcDto).to receive(:new).with(
      chain: rpc_params[:chain],
      testnet: rpc_params[:testnet],
      address: rpc_params[:address],
      method: rpc_params[:method],
      block_tag: rpc_params[:block_tag],
      block_number: rpc_params[:block_number],
      full_transaction: rpc_params[:full_transaction],
    ).and_return(dto)
    end

    context 'with valid parameters' do
      before do
        allow(Blockchain::Evm::Rpc).to receive(:for).with(dto).and_return({ result: 100 })
      end

      it 'it returns 200' do
        post :call, params: request_params
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid parameters' do
      let(:dto) do
        instance_double(
          Evm::RpcDto,
          valid?: false,
          chain: 'ethereum',
          testnet: false,
          method: :get_balance,
          address: '0x0000000000000000000000000000000000000000',
          block_tag: 'latest',
          block_number: nil,
          full_transaction: true,
          errors: { chain: 'invalid chain' }
        )
      end

      it 'returns 400' do
        post :call, params: request_params
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
