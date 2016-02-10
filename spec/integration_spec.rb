require 'spec_helper'
require 'webmock/rspec'
require 'with_env'

describe 'howareyou.mobi', type: :request do
  include WithEnv

  before { PhoneNumber.create!(number: '+15551212') }

  context 'when inviting a new user' do
    it 'sends a text message to that user' do
      with_env('TWILIO_NUMBER' => '+15554444') do
        stub = stub_request(:post, 'https://fake_token:fake_token@api.twilio.com/2010-04-01/Accounts/fake_token/Messages.json')
               .with(body: { 'Body' => 'Hi, how are you? Tell me with an emoji and a short message.', 'From' => '+15554444', 'To' => '+17777777' })
               .and_return(body: '{}')

        get '/sms', 'Body' => 'Invite +17777777', 'From' => '+15551212', 'To' => '+15554444'

        expect(response.body).to match %r{<\?xml version="1.0" encoding="UTF-8"\?><Response><Message>.*</Message></Response>}
        expect(response.status).to eq 200
        expect(stub).to have_been_requested
      end
    end
  end

  context 'when receiving text messages from a valid phone number' do
    it 'responds with a emoji text message' do
      get '/sms', 'From' => '+15551212', 'Body' => '', 'To' => ''
      expect(response.body).to match %r{<\?xml version="1.0" encoding="UTF-8"\?><Response><Message>.*</Message></Response>}
      expect(response.status).to eq 200
    end

    context 'with multiple phone numbers' do
      before { PhoneNumber.create!(number: '+15554444') }

      it 'responds with a emoji text message' do
        get '/sms', 'From' => '+15554444', 'Body' => '', 'To' => ''
        expect(response.body).to match %r{<\?xml version="1.0" encoding="UTF-8"\?><Response><Message>.*</Message></Response>}
        expect(response.status).to eq 200
      end
    end
  end

  context 'when receiving text messages from a invalid phone number' do
    it 'responds nothing' do
      get '/sms', 'From' => '', 'Body' => '', 'To' => ''
      expect(response.body).to eq ''
      expect(response.status).to eq 401
    end
  end
end
