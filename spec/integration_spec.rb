require 'spec_helper'
require 'rack/test'
require 'with_env'

describe 'howareyou.mobi', type: :request do
  include WithEnv

  context 'when receiving text messages from a valid phone number' do
    it 'responds with a emoji text message' do
      with_env('PHONE_NUMBER' => '+15551212') do
        get '/sms', 'From' => '+15551212', 'Body' => '', 'To' => ''
        expect(response.body).to match %r{<\?xml version="1.0" encoding="UTF-8"\?><Response><Message>.*</Message></Response>}
        expect(response.status).to eq 200
      end
    end

    context 'with multiple phone numbers' do
      it 'responds with a emoji text message' do
        with_env('PHONE_NUMBER' => '+15551212,+15554444') do
          get '/sms', 'From' => '+15554444', 'Body' => '', 'To' => ''
          expect(response.body).to match %r{<\?xml version="1.0" encoding="UTF-8"\?><Response><Message>.*</Message></Response>}
          expect(response.status).to eq 200
        end
      end
    end
  end

  context 'when receiving text messages from a invalid phone number' do
    it 'responds nothing' do
      with_env('PHONE_NUMBER' => '+15551212') do
        get '/sms', 'From' => '', 'Body' => '', 'To' => ''
        expect(response.body).to eq ''
        expect(response.status).to eq 401
      end
    end
  end
end
