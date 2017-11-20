# -*- coding: utf-8 -*-
require_relative './toot'
require_relative './model/site'
require_relative './model/item'


Plugin.create(:mastodon) do
  random = Random.new
  i = 0
  cw  = ""
  info_toot = []


  tl = "home"
  settings "Mastodon" do
#    UserConfig[:host] ||= :host
#    UserConfig[:token] ||= :token
#    boolean("Mastodonに投稿する", :mastodon_post)
#    input(_("URL"), account[:host])
#    input(_("とーくん"), account[:token])
<<<<<<< HEAD
    select("公開範囲", :mastodon_vis, { 0 => "公開", 1 => "非収載", 2 => "非公開", 3 => "ダイレクト" , 4=> "Random"})
=======
    select("公開範囲", :mastodon_vis, { 0 => "公開", 1 => "非収載", 2 => "非公開", 3 => "ダイレクト" })
>>>>>>> f5d57a1deb796a7a16ccd24e221f3a36fd3f25ec
  end

  account = {
    :token => "",
    :host => ""
  }
  account[:status_url] = "https://" + account[:host] + "/api/v1/statuses"
  tab :mastodon_home, 'HomeTimeline' do
    set_icon "https://#{account[:host]}/favicon.ico"
    timeline :mastodon_home
  end  
  

  filter_gui_postbox_post do |gui_postbox, opt|
    if UserConfig[:mastodon_post]
      text = Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text
      vis = 
        case UserConfig[:mastodon_vis]
        when 0 then
          vis = "public"
        when 1 then
          vis = "unlisted"
        when 2 then
          vis = "private"
        when 3 then
          vis = "direct"
        when 4 then
          case random.rand(1..400)
          when 1..100 then
            vis = "public"
          when 101..200 then
            vis = "unlisted"
          when 201..300  then
            vis = "private"
          when 301..400 then
            vis = "direct"
          else
            activity :system, "0から3までの乱数が0から3以外の数値を出したよ！\nすごいね！どう考えてもバグだね！"
          end
        else
          vis = "public"
        end


      
      PostToot(text, vis, cw, account)

      Thread.new{  
        JSON.parse(res.body)
     
        activity :system,  "test"
      }.next{|toot|
        result = toot
        activity :system,  "test"
        [Plugin::Mastodon::Site.new(name: result[account[display_name]],
                                    description: result[account[note]],
                                    link: result[account[url]],
                                    created: result[account[created_at]],
                                    feed_url: result[account[url]],
                                    profile_image_url: result[account[avatar]]), user]
      }.next{|site, user, result|
        activity :system, "test"
        Plugin::Mastodon::Item.new(guid: result[id],
                                   link: result[url],
                                   title: "null",
                                   description: result[content],
                                   created: result[created_at],
                                   site: site)
      }.next{|item|
        activity :system,  "test"
        timeline(:mastodon_home) << item
      }
      Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer.text = ""
    end
  end
  on_boot do |service|
  end
end
