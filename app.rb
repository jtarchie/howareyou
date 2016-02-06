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
  def create
    number = params.fetch('From')
    unless number == ENV.fetch('PHONE_NUMBER')
      self.status = 401
      self.response_body = ''
    else
      responses = ("\u{1F601}".."\u{1F64F}").to_a
      response  = responses.sample
      Message.create(
        incoming_message: params.fetch('Body'),
        outgoing_message: response,
        from_number:      params.fetch('From'),
        to_number:        params.fetch('To')
      )

      twiml = Twilio::TwiML::Response.new do |r|
        r.Message response
      end
      self.response_body = twiml.text
    end
  end
end

class HowAreYouApp < Rails::Application
  routes.append do
    get '/sms' => 'messages#create'
  end

  config.cache_classes = true

  # uncomment below to display errors
  config.consider_all_requests_local = Rails.env.development?

  # We need a secret token for session, cookies, etc.
  config.secret_key_base = ENV.fetch('SECRET_KEY_BASE')
end

HowAreYouApp.initialize!
