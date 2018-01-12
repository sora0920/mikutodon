# -*- coding: utf-8 -*-
require "thread"
require 'net/http'
require 'uri'
require "json"
require "eventmachine"
require "faye/websocket"
require 'nokogiri'
require_relative './model'
require_relative "./stream"
require_relative "./toot_operation"
require_relative "./account_setup"
require_relative "./user_operation"
require_relative "./mikutodon_parser"

Plugin.create(:mikutodon) do
  cw  = ""
  vis = "public"

  filter_extract_datasources do |ds|
    Enumerator.new{|y|
      Plugin.filtering(:worlds, y)
    }.select{|world|
      world.class.slug == :mikutodon
    }.each{|world|
      ds["MikutodonHomeTimeline_#{world.title}"] = "MikutodonHomeTimeline(#{world.title})" 
      ds["MikutodonLocalTimeline_#{world.title}"] = "MikutodonLocalTimeline(#{world.title})" 
      ds["MikutodonPublicTimeline_#{world.title}"] = "MikutodonPublicTimeline(#{world.title})" 
    }
    [ds]
  end

  world_setting(:mikutodon, "Mastodon") do
    label _("インスタンスのドメイン(例: Twitter.com)を入力しOKを押してください。")
    input "Host", :host

    result = await_input
    label _("リンクを開きリンク先で表示された認証コードを入力しOKを押してください")
    link create_link(result[:host])
    input "code", :code

    result = await_input

    world = Plugin::Mikutodon::World.build(get_token(result[:code], result[:host]), result[:host])

    label "このアカウントでログインしますか？"
    link world.user

    world
  end

  defspell(:compose, :mikutodon, 
           condition: -> lambda{ true }
          ) do |mikutodon, body: |
            post_toot(body, "", {host: mikutodon.host, token: mikutodon.token}, "public")
          end

  defspell(:favorite, :mikutodon, :mstdn_toot,
           condition: -> lambda{ true }
          ) do |mikutodon, toot |
            mstdn_fav(toot.id, {host: mikutodon.host, token: mikutodon.token})
          end

  defactivity "mstdn_fav", "mikutodon ふぁぼ"
  defactivity "mstdn_reblog", "mikutodon ぶーすと"
  defactivity "mstdn_follow", "mikutodon ふぉろー"
  defactivity "mstdn_mention", "mikutodon 返信"
  defactivity "mikutodon_debug_message", "mikutodon デバックメッセージ"

  settings "mikutodon" do
    # エラー対策
    # boolean("Mastodonに投稿する", :mastodon_post)
    input(_("インスタンスのドメイン名"), :account_host)
    input(_("とーくん"), :account_token)
    input(_("CW使用時の警告文"), :cw_text)
    select("公開範囲", :mastodon_vis, { 0 => "公開", 1 => "非収載", 2 => "非公開", 3 => "ダイレクト" , 4=> "Random"})
  end

  # アカウント
  account = {
    :token => UserConfig[:account_token],
    :host => UserConfig[:account_host]
  }

  defimageopener("MastodonMedia", /#{URI.regexp}\/media\//){ |url|
    open(url)
  }




  # ふぁぼふぁぼこまんど
  command(:mastodon_fav,
          name: "お気に入り",
          condition: lambda{ |opt|
            opt.messages.any? { |message|
              message.is_a?(Plugin::Mikutodon::Toot) 
            }
          },
          visible: true,
          role: :timeline) do |opt|
    opt.messages.select { |_| _.is_a?(Plugin::Mikutodon::Toot) }.each { |message|
      mstdn_fav(message[:id], account).trap { |err|
        error err
      }
    }
  end

  command(:mastodon_reblog,
          name: "ブースト",
          condition: lambda{ |opt|
            opt.messages.any? { |message|
              message.is_a?(Plugin::Mikutodon::Toot) && (message[:visibility] == ("public" || "unlisted"))
            }
          },
          visible: true,
          role: :timeline) do |opt|
    opt.messages.select { |_| _.is_a?(Plugin::Mikutodon::Toot) }.each { |message|
      mstdn_reblog(message[:id], account).trap { |err|
        error err
      }
    }
  end

#  command(:mstdn_tl_retry,
#          name: "ストリーミングの再接続",
#          condition: lambda{ |opt| $tl_close },
#          visible: true,
#          role: :timeline) do |opt|
#    timeline_start(account)
#  end

  # CWで投稿するコマンドを追加
  command(:mastodon_cw,
          name: "CWで投稿",
          condition: lambda{ |opt| true },
          visible: true,
          role: :postbox) do |opt|
    cw_text = UserConfig[:cw_text]

    # もしCWの文章が指定されていなかった場合は自動で閲覧注意を挿入
    if cw_text.empty?
      cw_text = "閲覧注意！"
    end

    text = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    post_toot(text, cw_text, account, UserConfig[:mastodon_vis]).next {
      # 投稿成功時のみバッファをクリア
      Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ""
    }.trap { |err|
      error err
    }
  end



  # Mastodonに投稿
  command(:mastodon_toot,
          name: "Mastodonに投稿する",
          condition: lambda{ |opt| true },
          visible: true,
          role: :postbox) do |opt|
    text = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text

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
      activity :mikutodon_debug_message, "正規表現だよ！"
    end

    post_toot(text, cw, account, UserConfig[:mastodon_vis]).next {
      # 投稿成功時のみバッファをクリア
      Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ""
    }.trap { |err|
      error err
    }


#    end
  end

  # タイムラインの開始を開始
  on_boot do |service|
    #timeline_start(account)
  end


end

