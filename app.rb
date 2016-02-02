require 'sinatra'
require 'sinatra/activerecord'
require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = ENV.fetch 'TWILIO_ACCOUNT_SID'
  config.auth_token  = ENV.fetch 'TWILIO_AUTH_TOKEN'
end

class Message < ActiveRecord::Base
end

get '/sms' do
  number = params[:From]
  return unless number == ENV.fetch('PHONE_NUMBER')

  responses = ("\u{1F601}".."\u{1F64F}").to_a
  response  = responses.sample
  Message.create(
    incoming_message: params[:Body],
    outgoing_message: response,
    from_number:      params[:From],
    to_number:        params[:To]
  )

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message response
  end
  twiml.text
end
