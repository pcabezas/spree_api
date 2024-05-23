module WebPay
  class Api
    def initialize
    end

    def generate_token(buy_order:, session_id:, amount:)
      connection = Faraday.new('http://webpay-app:3060/webpay-plus/')
      payload = { buyOrder: buy_order,
                  sessionId: session_id,
                  amount: amount }
      response = connection.post('transactions/create', payload.to_json, { 'Content-Type' => 'application/json' })
    end

    def result(token)
      connection = Faraday.new('http://webpay-app:3060/webpay-plus/')
      response = connection.get("transactions/result?token_ws=#{token}")
    end
  end
end
