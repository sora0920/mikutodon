# mikutodon
mikutterでmastodonできるプラグイン
# これなに
mikutterでMastodonやれるやつ
# インストール方法
1. これを叩く
```
mkdir -p ~/.mikutter/plugin
cd ~/.mikutter/plugin
git clone git@github.com:sora0920/mikutodon.git
```
2. お好きな方法でGemを突っ込む
```
gem "eventmachine"
gem "faye-websocket"
gem "nokogiri"
```
3. MastodonからトークンとインスタンスのURLを取ってきてユーザーコンフィグに突っ込む
4. 再起動すれば抽出タブのデータソースが増えてるよ！やったねミクちゃん！
# コマンド一覧
- タイムライン
   - Tootを選択した状態
      - ブースト
      - ふぁぼ
   - タイムラインの接続に失敗した状態のタイムライン上
      - ストリーミングの再接続
- 投稿欄
   - CWで投稿
# CWと公開範囲について
CWはユーザーコンフィグで指定した文章を警告文に指定して投稿します    
公開範囲もユーザーコンフィグでの事前設定になります
# プルリク
歓迎

