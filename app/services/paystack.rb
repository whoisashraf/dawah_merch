class Paystack
  BASE_URL = "https://api.paystack.co"

  def initialize
    @secret_key = ENV["PAYSTACK_SECRET_KEY"]
  end

  def initialize_transaction(email:, amount:, reference:, callback_url:)
    post("/transaction/initialize", {
      email: email,
      amount: amount,
      reference: reference,
      callback_url: callback_url
    })
  end

  def verify_transaction(reference)
    get("/transaction/verify/#{reference}")
  end

  def verify_webhook(body, signature)
    return false if @secret_key.blank? || signature.blank?
    hash = OpenSSL::HMAC.hexdigest("SHA256", @secret_key, body)
    ActiveSupport::SecurityUtils.secure_compare(hash, signature)
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def post(path, body)
    connection.post(path, body) do |req|
      req.headers["Authorization"] = "Bearer #{@secret_key}"
      req.headers["Content-Type"] = "application/json"
    end
  end

  def get(path)
    connection.get(path) do |req|
      req.headers["Authorization"] = "Bearer #{@secret_key}"
    end
  end
end
