class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
				when Line::Bot::Event::MessageType::Text
					image_url = [
						'https://i.gyazo.com/8d8be142e1ca2ce3be59deaaac3dd0ad.jpg',
						'https://i.gyazo.com/49fd971b7eecf40a0180c1d035280609.jpg',
						'https://gyazo.com/894e8dcad8e5ace4f1b86f89ec277850.jpg'
											]
          message = {
            type: 'image',
						originalContentUrl: image_url.sample,
						previewImageUrl: image_url.sample
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end

