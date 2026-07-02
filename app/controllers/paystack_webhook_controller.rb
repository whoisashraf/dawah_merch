class PaystackWebhookController < ApplicationController
  allow_unauthenticated_access only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    payload = request.body.read
    signature = request.headers["x-paystack-signature"]

    Rails.logger.info "[Paystack Webhook] === Event received ==="
    Rails.logger.info "[Paystack Webhook] Signature present: #{signature.present?}"
    Rails.logger.info "[Paystack Webhook] Payload size: #{payload.bytesize} bytes"
    Rails.logger.info "[Paystack Webhook] Headers: #{request.headers.to_h.select { |k,_| k.start_with?("HTTP_") || k.start_with?("CONTENT_") }.inspect}"

    paystack = Paystack.new

    unless paystack.verify_webhook(payload, signature)
      Rails.logger.warn "[Paystack Webhook] ⚠ INVALID SIGNATURE — rejecting"
      head :unauthorized and return
    end

    Rails.logger.info "[Paystack Webhook] ✅ Signature verified successfully"

    event = JSON.parse(payload)
    Rails.logger.info "[Paystack Webhook] Event type: #{event["event"]}"
    Rails.logger.info "[Paystack Webhook] Data: #{event["data"].to_json}"

    if event["event"] == "charge.success"
      reference = event.dig("data", "reference")
      amount = event.dig("data", "amount")
      status = event.dig("data", "status")
      Rails.logger.info "[Paystack Webhook] charge.success — ref: #{reference}, amount: #{amount}, status: #{status}"

      order = Order.find_by(reference: reference)

      if order.nil?
        Rails.logger.warn "[Paystack Webhook] ⚠ Order not found for reference: #{reference}"
      elsif order.paid?
        Rails.logger.info "[Paystack Webhook] Order #{reference} already marked as paid, skipping"
      elsif amount.to_i != order.total_amount
        Rails.logger.error "[Paystack Webhook] ⚠ AMOUNT MISMATCH — order total: #{order.total_amount}, paid: #{amount} (ref: #{reference})"
        order.update!(payment_status: "failed", status: "cancelled")
      else
        order.update!(payment_status: "paid", status: "processing")
        Rails.logger.info "[Paystack Webhook] ✅ Order #{reference} marked as paid"
      end
    else
      Rails.logger.info "[Paystack Webhook] Ignoring non-charge.success event"
    end

    head :ok
  end
end
