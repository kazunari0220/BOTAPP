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
        response = ["大好きだよ","めいちゃんと居ると素で居られるよ！","すみれが会いたがってるよ","疲れた時は一緒に寝ようね(_ _).｡o○","一緒に居ようね。","いつでもうちにおいで！","めいちゃんから一成へ","めっちゃ好き！！","一年間支えてくれてありがとう","うんこめい！！","飲み過ぎ注意（怒）","今日もお疲れ様","もう少しで今年も終わるね。2021年はどんな年になるかな？","可愛いね♡","塩昆布食べたい","愛してるよ","スノボー行きたい！連れてけめい！","キキちゃんが会いたがってるよ！","岩盤浴行くぞー！！！","好きだよ","ダイエットは( ͡° ͜ʖ ͡°)？","一成が会いたがってるよ。","一成とキキとすみれとベーコンが会いたがってるよ。あ！ハムも会いたいって"].shuffle.first
      elsif event.message['text'].include?("1")
        response = "私達は気づかないうちに自分に制限をかけている事が多いものです。「私はこういう性格だから」「経験がないから」と、やってもいないのに自分の可能性を決めつけて諦めている事はないでしょうか。ラルフ・ウォルドー・エマソンは「自己啓発の祖」といわれる思想家です。成功への心構えとして「常に自己をよりどころに行きよ」と主張しました。自己信頼の「自己」とは、ただ好き放題に生きるエゴとは違います。エマソンは、謙虚な心で自分が本当に望む事をするなら、人間はもっと自由に幸福になれると説いています。"
      else
        response = ["限界を設けているのも自分、可能性を信じているのも自分。-ラルフ・ウォルドー・エマソン-[思想家・哲学者] 詳細No.１",
        "行く手に川があったら渡ればいいじゃないか。-トーマス・エジソン-[発明家]",
        "細部にこだわる。それは時間をかけてもこだわる価値のあるものだ。-スティーブ・ジョブズ-",
        "成功者になろうとするな。価値ある者になろうとせよ。-アルバート・アインシュタイン-",
        "ディズニーランドが完成することはない。想像力が世の中にある限り進化し続けるだろう。-ウォルト・ディズニー-",
        "人生はクローズアップで見れば悲劇だが、ロングショットで見れば喜劇だ。-チャーリー・チャップリン-[俳優・映画監督]",
        "失敗したからって何なのだ？失敗から学びを得て、また挑戦すればいいじゃないか？-ウォルト・ディズニー-",
        "成功とは、どん底に落ちた時、どれほど高く跳ね上がれるか、ということである。-ジョージ・パットン-[陸軍軍人]"].shuffle.first
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
