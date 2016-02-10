require 'active_record/railtie'
require 'action_controller/railtie'
require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = ENV.fetch 'TWILIO_ACCOUNT_SID'
  config.auth_token  = ENV.fetch 'TWILIO_AUTH_TOKEN'
end

class Message < ActiveRecord::Base
end

class MessagesController < ActionController::Metal
  MESSAGES_REACTOR = {
    /^Invite (.*)$/ => lambda do |matches|
      client = Twilio::REST::Client.new
      client.messages.create(
        from: ENV.fetch('TWILIO_NUMBER'),
        to: matches[1],
        body: 'Hey there!'
      )
    end
  }.freeze

  def create
    return unless validate_phone_number!

    outgoing_messages = ("\u{1F601}".."\u{1F64F}").to_a
    outgoing_message  = outgoing_messages.sample

    record_message!(outgoing_message)

    MESSAGES_REACTOR.each do |matcher, block|
      matches = params.fetch('Body', '').match(matcher)
      if matches
        block.call(matches)
        break
      end
    end

    twiml = Twilio::TwiML::Response.new do |r|
      r.Message outgoing_message
    end
    self.response_body = twiml.text
  end

  private

  def record_message!(message)
    Message.create(
      incoming_message: params.fetch('Body'),
      outgoing_message: message,
      from_number:      params.fetch('From'),
      to_number:        params.fetch('To')
    )
  end

  def validate_phone_number!
    unless ENV.fetch('PHONE_NUMBER').split(',').include?(params.fetch('From'))
      self.status = 401
      self.response_body = ''
      return false
    else
      return true
    end
  end
end

class HowAreYouApp < Rails::Application
  routes.append do
    get '/sms' => 'messages#create'
  end

  unless Rails.env.test?
    config.middleware.use(Rack::TwilioWebhookAuthentication, ENV['TWILIO_AUTH_TOKEN'], '/sms')
  end

  config.cache_classes = true

  # uncomment below to display errors
  config.consider_all_requests_local = Rails.env.development? || Rails.env.test?

  # We need a secret token for session, cookies, etc.
  config.secret_key_base = ENV.fetch('SECRET_KEY_BASE')
end

HowAreYouApp.initialize!
