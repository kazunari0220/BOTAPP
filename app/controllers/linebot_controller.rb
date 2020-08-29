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
      if event.message['text'].include?("一成からめいちゃんへ")
        response = ["大好きだよ","愛してるよ","好きだよ","一緒に居ようね。"].shuffle.first
      else
        response = ["限界を設けているのも自分、可能性を信じているのも自分。-ラルフ・ウォルドー・エマソン-[思想家・哲学者]",
        "行く手に川があったら渡ればいいじゃないか。-トーマス・エジソン-[発明家]",
        "細部にこだわる。それは時間をかけてもこだわる価値のあるものだ。-スティーブ・ジョブズ-",
        "成功者になろうとするな。価値ある者になろうとせよ。-アルバート・アインシュタイン-",
        "ディズニーランドが完成することはない。想像力が世の中にある限り進化し続けるだろう。-ウォルト・ディズニー-",
        "成功とは、どん底に落ちた時、どれほど高く跳ね上がれるか、ということである。-ジョージ・パットン-[陸軍軍人]"].shuffle.first
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            "type": "template",
            "altText": "This is a buttons template",
            "template": {
              "type": "buttons",
              "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
              "imageAspectRatio": "rectangle",
              "imageSize": "cover",
              "imageBackgroundColor": "#FFFFFF",
              "title": "Menu",
              "text": "Please select",
              "defaultAction": {
                "type": "uri",
                "label": "View detail",
                "uri": "http://example.com/page/123"
              },
              "actions": [
              ]
            }
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
