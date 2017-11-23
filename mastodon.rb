# -*- coding: utf-8 -*-
require_relative './toot'
require_relative './model/site'
require_relative './model/item'


Plugin.create(:mastodon) do
  # ランダム公開範囲用の乱数
  random = Random.new
  cw  = ""
  vis = "public"


  tl = "home"

  settings "Mastodon" do
#    実装予定の設定ですがこの状態だと設定を開くとクラッシュするのでコメントアウト
#    UserConfig[:host] ||= :host
#    UserConfig[:token] ||= :token
#    boolean("Mastodonに投稿する", :mastodon_post)
    input(_("URL"), :account_host)
    input(_("とーくん"), :account_token)
    input(_("CW使用時の警告文"), :cw_text)
    select("公開範囲", :mastodon_vis, { 0 => "公開", 1 => "非収載", 2 => "非公開", 3 => "ダイレクト" , 4=> "Random"})
  end

  account = {
    :token => UserConfig[:account_token],
    :host => UserConfig[:account_host]
  }

  # タイムラインを作る
  tab :mastodon_home, 'HomeTimeline' do
    set_icon "https://#{account[:host]}/favicon.ico"
    timeline :mastodon_home
  end  
  
  # CWで投稿するコマンド
  command(:mastodon_cw,
          name: "CWで投稿",
          condition: lambda{ |opt| true },
          visible: true,
          role: :postbox) do |opt|
    cw_text = UserConfig[:cw_text]

    # もしコンフィグ上のCWテキストが空だった場合には警告文を追加する
    if cw_text.empty?
      cw_text = "閲覧注意！"
    end

    text = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text 
    post_toot(text, cw_text, account, UserConfig[:mastodon_vis])    

    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ""
  end



  # 投稿欄を乗っ取る
  filter_gui_postbox_post do |gui_postbox, opt|
    text = Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text

    # 投稿する
    post_toot(text, cw, account, UserConfig[:mastodon_vis])

    # 投稿欄を空に
    Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text = ""

#    試してるコードをコメントアウト
#    Thread.new{  
#      JSON.parse(res.body)
#   
#      activity :system,  "test"
#    }.next{|toot|
#      result = toot
#      activity :system,  "test"
#      [Plugin::Mastodon::Site.new(name: result[account[display_name]],
#                                  description: result[account[note]],
#                                  link: result[account[url]],
#                                  created: result[account[created_at]],
#                                  feed_url: result[account[url]],
#                                  profile_image_url: result[account[avatar]]), user]
#    }.next{|site, user, result|
#      activity :system, "test"
#      Plugin::Mastodon::Item.new(guid: result[id],
#                                 link: result[url],
#                                 title: "null",
#                                 description: result[content],
#                                 created: result[created_at],
#                                 site: site)
#    }.next{|item|
#      activity :system,  "test"
#      timeline(:mastodon_home) << item
#    }

  end

  on_boot do |service|
  end
end

