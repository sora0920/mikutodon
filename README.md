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
3. MastodonからトークンとインスタンスのURL(https:// を抜いたドメインのみ)を取ってきてユーザーコンフィグに突っ込む
4. 再起動すれば抽出タブのデータソースが増えてるよ！やったねミクちゃん！
# Mastodonのトークンのとり方
1. トークンのとり方
  1. https://インスタンスのドメイン/settings/applications (内容は自分のインスタンスに合わせる)にアクセスする
  2. 新規アプリを押す
  3. アプリの名前(自由に)を入力する
  4. 送信を押す
  5. 画面が戻るので作成したアプリの名前を押す
  6. アクセストークンが手に入る
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
CWの警告文と公開範囲はユーザーコンフィグで事前設定してください。
# プルリク
歓迎

