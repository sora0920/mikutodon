# -*- coding: utf-8 -*-
require "thread"
require "json"
require "eventmachine"
require "faye/websocket"
require 'nokogiri'
require_relative './toot'
require_relative "./stream"
require_relative './model.rb'
require_relative "./command"


Plugin.create(:mikutodon) do
  # ランダム公開範囲用乱数
  random = Random.new
  cw  = ""
  vis = "public"


  filter_extract_datasources do |ds|
    [ds.merge(mastodon: 'Mastodon')]
  end


  settings "mikutodon" do
     # エラー対策
#    boolean("Mastodonに投稿する", :mastodon_post)
    input(_("URL"), :account_host)
    input(_("とーくん"), :account_token)
    input(_("CW使用時の警告文"), :cw_text)
    select("公開範囲", :mastodon_vis, { 0 => "公開", 1 => "非収載", 2 => "非公開", 3 => "ダイレクト" , 4=> "Random"})
  end

  # アカウント
  account = {
    :token => UserConfig[:account_token],
    :host => UserConfig[:account_host]
  }


  # Mastodon用タイムラインの生成
  tab :mastodon_home, 'HomeTimeline' do
    set_icon "https://#{account[:host]}/favicon.ico"
    timeline :mastodon_home
  end  
 
  tab :mastodon_local, "LocalTimeline" do
    set_icon "https://#{account[:host]}/favicon.ico"
    timeline :mastodon_local
  end

  tab :mastodon_public, "PublicTimeline" do
    set_icon "https://#{account[:host]}/favicon.ico"
    timeline :mastodon_public
  end

  
  # タイムラインのストリームをスタート
  def timeline_start(account)
    Thread.new{
      toots_home = []
      stream(account, "user", :mastodon_home, toots_home)
    }
    Thread.new{
      toots_local = []
      stream(account, "public:local", :mastodon_local, toots_local)
    }
    Thread.new{
      toots_public = []
      stream(account, "public", :mastodon_public, toots_public)
    }

  end

  # 表示条件を満たすデータに加工
  def create_toot(status)
    status_parse = JSON.parse(status)

    created_time = status_parse["created_at"]

    data = if status_parse["reblog"].empty?
      status_parse
    else 
      status_parse["reblog"]
    end
 

    # HTMLのParse
    toot_body = Nokogiri::HTML.parse(data["content"],nil,"UTF-8").text

    
    user_name = if data["account"] ["display_name"].empty?
      data["account"] ["username"]
    else
      data["account"] ["display_name"]
    end

  
    user = MstdnUser.new_ifnecessary(
      name: user_name,
      link: data["account"] ["url"],
      created: Time.parse(data["account"] ["created_at"]).localtime,
      profile_image_url: data["account"] ["avatar"],
      id: data["account"]["id"].to_i
    )
    
    toot = MstdnToot.new_ifnecessary(
      id: data["id"].to_i,
      link: data["url"],
      description: toot_body,
      created: Time.parse(created_time).localtime,
      user: user
    )
    
    return toot
  end



  # 投稿欄を乗っ取りMastodonに投稿
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

    post_toot(text, cw, account, UserConfig[:mastodon_vis])

    
#    end

    Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text = ""
  end
    
  # タイムラインの開始を開始
  on_boot do |service|
    timeline_start(account)
  end


end

