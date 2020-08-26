class LinebotController < ApplicationController
  require 'line/bot'

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
      if event.message['text'].include?("名言")
        response = ["限界を設けているのも自分、可能性を信じているのも自分", 
        "行く手に川があったら渡ればいいじゃないか。byラルフ・ウォルドー・エマソン[思想家・哲学者]", "成功とは、どん底に落ちた時、どれほど高く跳ね上がれるか、ということである。byジョージ・パットン[陸軍軍人]"].shuffle.first
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: response
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
