module Spree
  class Gateway::WebPay < Gateway

    def provider_class
      ::WebPay::Api
    end

    def provider(order, payment)
      provider_class.new
    end

    def auto_capture?
      false
    end

    def confirmation_required?
      true
    end

    def source_required?
      false
    end

    def method_type
      'webpay'
    end

    def authorize(payment)
      order = payment.order
      response = provider(payment.order, payment).generate_token(buy_order: order.number, session_id: order.number, amount: payment.amount.to_i)
      if response.success?
        params = JSON.parse(response.body)
        payment.public_metadata[:token] = params['token']
        payment.public_metadata[:url] = params['url']
        payment.save
        true
      else
        false
      end
    end

    def purchase(payment)
      response = provider(payment.order, payment).result(payment.public_metadata[:token])
      if response.success?
        payment.complete!
        true
      else
        payment.failure!
        false
      end
    end

    def refund(payment, amount)
    end
  end
end
