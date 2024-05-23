module Spree
  module Api
    module V2
      module Storefront
        class WebpayController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::Storefront::OrderConcern
          before_action :ensure_order, only: [:init_transaction]

          def init_transaction
            order = @spree_current_order
            payment_id = require_webpay_token_params[:payment_id]
            payment = Spree::Payment.find(payment_id)
            gateway = payment.payment_method
            gateway.authorize(payment)
            params[:include] = 'payments' # include payments in the response
            render_serialized_payload(201) { serialize_resource(order) }
          end

          def transaction_result
            token = params[:token_ws]
            @payment = Spree::Payment.find_by("public_metadata ->> 'token' = ?", token)
            @order = @payment.order
            gateway = @payment.payment_method
            complete_service.call(order: @order) if gateway.purchase(@payment)
            redirect_to "http://0.0.0.0:3000/order/results?order_number=#{@order.number}"
          end

          private

          def require_webpay_token_params
            params.require(:webpay).permit(:payment_id)
          end

          def resource_serializer
            Spree::Api::Dependencies.storefront_cart_serializer.constantize
          end

          def complete_service
            Spree::Api::Dependencies.storefront_checkout_complete_service.constantize
          end
        end
      end
    end
  end
end
