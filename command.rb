require_relative './fav'
require_relative "./toot"

# ふぁぼふぁぼこまんど
command(:mastodon_fav,
        name: "お気に入り",
        condition: lambda{ |opt|
          opt.messages.any? { |message|
            message.is_a?(MstdnToot)
          }
        },
        visible: true,
        role: :timeline) { |opt|
    opt.messages.select { |_| _.is_a?(MstdnToot) }.each { |message|
      mstdn_fav(message[:id], account)
    }
  }

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
  post_toot(text, cw_text, account, UserConfig[:mastodon_vis])    

  Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ""
end
