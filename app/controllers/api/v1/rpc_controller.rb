class Api::V1::RpcController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from Apipie::ParamInvalid, with: :render_param_invalid
  rescue_from Apipie::ParamMissing, with: :render_param_missing

  api :GET, "/api/v1/rpc/resources", "Get available chains and RPC methods"
  def resources
    resources = Evm::ResourcesDto.from_constants # TODO: shouldn't be only for evm

    render json: resources.to_h
  end

  api :POST, "/api/v1/rpc/call", "Call a blockchain RPC method"
  param :dashboard, Hash, required: true do
    param :chain, String, required: true, desc: "Blockchain name (e.g. Ethereum)"
    param :method, String, required: true, desc: "RPC method to call (e.g. eth_getBalance)"
    param :testnet, :bool, required: false, desc: "Flag to indicate if the testnet is used", allow_blank: true
    param :address, String, required: false, desc: "Wallet address"
    param :block_tag, String, required: false, desc: "Block tag (e.g. latest, pending) or block number in decimal", allow_blank: true
    param :block_number, :number, required: false, desc: "Block number in decimal (e.g. 12345)", allow_blank: true
    param :full_transaction, :bool, required: false, desc: "Flag to indicate if full transaction details are required", allow_blank: true
  end
  def call
    dto = Evm::RpcDto.new(
      chain: rpc_params[:chain],
      testnet: rpc_params[:testnet],
      method: rpc_params[:method],
      address: rpc_params[:address],
      block_tag: rpc_params[:block_tag],
      block_number: rpc_params[:block_number],
      full_transaction: rpc_params[:full_transaction]
    )
    return render json: error_response(dto), status: :bad_request unless dto.valid?

    result = Blockchain::Evm::Rpc.for(dto)

    render json: success_response(dto, result)
  end

  api :POST, "/api/v1/rpc/:chain/balance/:address", "Get balance for an address"
  param :chain, String, in: :path, required: true, desc: "Blockchain name (e.g. Ethereum)"
  param :address, String, in: :path, required: true, desc: "Wallet address"
  param :testnet, :bool, in: :query, required: false, desc: "Flag to indicate if the testnet is used", allow_blank: true
  param :block_tag, String, in: :query, required: false, desc: "Block tag (e.g. latest) or block number in decimal", allow_blank: true
  def balance
    dto = Evm::RpcDto.new(
      chain: address_params[:chain],
      address: address_params[:address],
      testnet: address_params[:testnet],
      block_tag: address_params[:block_tag],
      method: :get_balance
    )

    return render json: error_response(dto), status: :bad_request unless dto.valid?

    result = Blockchain::Evm::Rpc.for(dto)

    render json: success_response(dto, result)
  end

  api :POST, "/api/v1/rpc/:chain/tx_count/:address"
  param :chain, String, in: :path, required: true, desc: "Blockchain name (e.g. Ethereum)"
  param :address, String, in: :path, required: true, desc: "Wallet address"
  param :testnet, :bool, in: :query, required: false, desc: "Flag to indicate if the testnet is used", allow_blank: true
  param :block_tag, String, in: :query, required: false, desc: "Block tag (e.g. latest) or block number in decimal", allow_blank: true
  def tx_count
    dto = Evm::RpcDto.new(
      chain: address_params[:chain],
      address: address_params[:address],
      testnet: address_params[:testnet],
      block_tag: address_params[:block_tag],
      method: :get_transaction_count
    )

    return render json: error_response(dto), status: :bad_request unless dto.valid?

    result = Blockchain::Evm::Rpc.for(dto)

    render json: success_response(dto, result)
  end

  api :GET, "/api/v1/rpc/:chain/current_block"
  param :chain, String, required: true, in: :path, desc: "Blockchain name (e.g. Ethereum)"
  param :testnet, :bool, required: false, in: :query, desc: "Flag to indicate if the testnet is used", allow_blank: true
  def block_number
    dto = Evm::RpcDto.new(
      chain: block_number_params[:chain],
      testnet: block_number_params[:testnet],
      method: :block_number
    )

    return render json: error_response(dto), status: :bad_request unless dto.valid?

    result = Blockchain::Evm::Rpc.for(dto)
    render json: success_response(dto, result)
  end

  api :POST, "/api/v1/rpc/:chain/block/:block_number"
  param :chain, String, in: :path, required: true, desc: "Blockchain name (e.g. Ethereum)"
  param :block_number, :number, in: :path, required: true, desc: "Block number in decimal (e.g. 12345)"
  param :testnet, :bool, in: :query, required: false, desc: "Flag to indicate if the testnet is used", allow_blank: true
  param :full_transaction, :bool, in: :query, required: false, desc: "Flag to indicate if full transaction details are required", allow_blank: true
  def block_by_number
    dto = Evm::RpcDto.new(
      chain: block_by_number_params[:chain],
      block_number: block_by_number_params[:block_number],
      testnet: block_by_number_params[:testnet],
      full_transaction: block_by_number_params[:full_transaction],
      method: :get_block_by_number
    )

    return render json: error_response(dto), status: :bad_request unless dto.valid?

    result = Blockchain::Evm::Rpc.for(dto)

    render json: success_response(dto, result)
  end

  private

  def block_by_number_params
    params.permit(:chain, :testnet, :block_number, :full_transaction)
  end

  def block_number_params
    params.permit(:chain, :testnet)
  end

  def address_params
    params.permit(:chain, :address, :testnet, :block_tag)
  end

  def balance_params
    params
      .permit(:chain, :address, :testnet, :block_tag)
      .merge(chain: params[:chain], address: params[:address], method: :get_balance)
  end

  def render_param_invalid(e)
    param_name = e.param.name
    render json: { error: "invalid parameter", param: param_name }, status: :bad_request
  end

  def render_param_missing(e)
    param_name = e.param.name
    render json: { error: "missing parameter", param: param_name }, status: :bad_request
  end

  def rpc_params
    params.require(:dashboard).permit(
      :chain,
      :testnet,
      :method,
      :address,
      :block_tag,
      :block_number,
      :full_transaction
    ).to_h
  end
end
