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

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
        client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
          if event.message['text'] =~ /おみくじ/
            message[:text] = 
                ["大吉", "中吉", "小吉", "凶", "大凶"].shuffle.first
          end
        end
      end
    end

    "OK"
  end
end

#   private

#   def template
#     {
#       "type": "template",
#       "altText": "this is a confirm template",
#       "template": {
#           "type": "confirm",
#           "text": "今日のもくもく会は楽しいですか？",
#           "actions": [
#               {
#                 "type": "message",
#                 # Botから送られてきたメッセージに表示される文字列です。
#                 "label": "楽しい",
#                 # ボタンを押した時にBotに送られる文字列です。
#                 "text": "楽しい"
#               },
#               {
#                 "type": "message",
#                 "label": "楽しくない",
#                 "text": "楽しくない"
#               }
#           ]
#       }
#     }
#   end
# end
