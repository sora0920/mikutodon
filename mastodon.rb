# -*- coding: utf-8 -*-
require "thread"
require_relative './toot'
require_relative './model.rb'


Plugin.create(:mastodon) do
# ランダム公開範囲用乱数
  random = Random.new
  cw  = ""
  vis = "public"


  filter_extract_datasources do |ds|
    [ds.merge(mastodon: 'Mastodon')]
  end

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

# アカウントの配列
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
   #投稿欄から文字列を取得しToot 
    text = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text 
    post_toot(text, cw_text, account, UserConfig[:mastodon_vis])    
    # 投稿欄を空に
    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ""
  end

# 投稿欄を乗っ取る
  filter_gui_postbox_post do |gui_postbox, opt|
    text = Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text
  # もし投稿内容が正規表現なら警告する機能(未実装)    
    if text =~ /^s\/.+\/.+\/?$/
#      req_warn = Gtk::Dialog.new
#
#
#      label_str = Gtk::Label.new("失った信頼はもう戻ってきませんが、本当にこの文章を投稿しますか？\n\n#{text}")
#
#      label_str.show
#
#      req_warn.vbox.pack_start(label_str, true, true, 30)
#
#
#      req_warn.add_buttons(["No", Gtk::Dialog::RESPONSE_NO],["Yes", Gtk::Dialog::RESPONSE_YES])
#
#      req_warn.signal_connect("response") do |widget, responsei|
#        case response
#        when Gtk::Dialog::RESPONSE_YES
#          post_toot(text, cw, account, UserConfig[:mastodon_vis])
#        when Gtk::Dialog::RESPONSE_NO
#          activity :system, "test"
#        end
#      end
#      req_warn.show_all
#    else
      activity :system, "正規表現だよ！"
    end
#   投稿する
    post_toot(text, cw, account, UserConfig[:mastodon_vis])
#    end
    # 投稿欄を空に
    Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text = ""
  end

# タイムラインにTootを追加するテスト(タイムラインに固定の内容の投稿を追加することには成功してます)
  def test_1 
#    activity :system, "!" 
    user = MstdnUser.new_ifnecessary(
      name: "TestUser",
      link: "https://mstdn.maud.io/@Non",
      created: Time.at(0),
      profile_image_url: "https://mstdn.maud.io/favicon.ico",
      id: 1
    )
#    activity :system, "user!"
    toot = MstdnToot.new_ifnecessary(
      id: 1,
      link: "https://mstdn.maud.io/favicon.ico",
      description: "てすと！",
      created: Time.at(0),
      user: user
    )
#    activity :system, "toot!"
    
    return toot
  end
# タイムラインにTootを追加
  on_period { |service|
    toots = []
    toots.push(test_1)
    toots.push(test_1)
    timeline(:mastodon_home) << toots
  }

  on_boot do |service|
  end
end

