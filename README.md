# Cloud Translation API

Google Cloud Platform の Cloud Translation API を使って翻訳アプリを作っていく。

今回は Rails アプリに英語の文字列を日本語に変換するアプリを作成する。

作業順序

1. Google Cloud Platform にアクセス
2. Cloud Translation API の API を有効にする
3. 認証情報(API key)を作成する
4. API キーを編集して、API キーの名前を変更して API キーを制限する
5. 認証情報で JSON を作成する
6. Rails プロジェクトを作成
7. Google Translation 用の gem を追加
8. Google Cloud client library をインポートするための記述
9. config 下に google_cloud.json、local_env.yml に JSON データを入れる
10. gitignore ファイルに google_cloud.json、local_env.yml を入れる
11. ローカル環境ファイルの読み込み設定のための記述を application.rb ファイルにする
12. translate コントローラー作成
13. ブラウザで確認

## Google Cloud Platform にアクセス

https://console.cloud.google.com

ここにアクセスしてアカウントを作成する。

## Cloud Translation API の API を有効にする

ハンバーガーメニューから、

API とサービス → ライブラリ →Cloud Translation API を検索して、Cloud Translation API を有効にすると以下のような画面になります。

<img width="839" alt="スクリーンショット 2021-10-02 0 49 40" src="https://user-images.githubusercontent.com/66903388/135650121-f54e758f-c2b7-4739-9522-518ec6bac303.png">

## 認証情報(API key)を作成する

認証情報ページ → 認証情報を作成 →API キー

<img width="998" alt="スクリーンショット 2021-10-02 0 58 26" src="https://user-images.githubusercontent.com/66903388/135651441-2a1a2ef2-ce2e-4be7-a775-dd2cb41d58f1.png">

## API キーを編集して、API キーの名前を変更して API キーを制限する

<img width="543" alt="スクリーンショット 2021-10-05 2 46 39" src="https://user-images.githubusercontent.com/66903388/135899184-553ff12a-8f07-46b5-a5bb-ede07aa280f0.png">

これで API キーの設定は完了です。

## 認証情報で JSON を作成する

これが後に作成する Rails アプリに必要になります。

<img width="921" alt="スクリーンショット 2021-10-02 1 09 45" src="https://user-images.githubusercontent.com/66903388/135653330-737f16e8-4b0b-4205-aa96-c21c00a63875.png">

この画面からサービスアカウントを作成したらサービスアカウントの編集ボタンを押す。

そして以下のように鍵を追加から JSON データを作成する。

<img width="1449" alt="スクリーンショット 2021-10-02 1 13 40" src="https://user-images.githubusercontent.com/66903388/135653536-8db653e8-c2db-43ab-90d9-b1f1ffb2b679.png">

作成した JSON データが入ったファイルはローカル PC 上に保存されます。

## Rails プロジェクト作成

```
$ rails new プロジェクト名
```

## Google Translation 用の gem を追加

Gemfile

```
gem "google-cloud"
gem "google-cloud-translate"
```

```
$ bundle install
```

## Google Cloud client library をインポートするための記述

config/application.rb

```
require "google/cloud/translate"
```

## config 下に google_cloud.json、local_env.yml に JSON データを入れる

config/google_cloud.json

```
{
 "type": "service_account",
 "project_id": "your_project_id", #=>これを使います
 "private_key_id": "04e00XXXXXXXXX",
 "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBg...p0Tg7WibPz76wqUFpGj/qshvY2pqFc2H94\nxkgZT44GHXagW5WOW5ofXJo=\n-----END PRIVATE KEY-----\n",
 "client_email": "random@random.iam.gserviceaccount.com",
 "client_id": "111111111111111",
 "auth_uri": "https://accounts.google.com/o/oauth2/auth",
 "token_uri": "https://oauth2.googleapis.com/token",
 "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
 "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/random%random.iam.gserviceaccount.com"
}
```

local_env.yml

```
CLOUD_PROJECT_ID: 'your_project_id' #=>google_cloud.jsonのproject_idから
GOOGLE_APPLICATION_CREDENTIALS: 'config/google_cloud.json'
```

## gitignore ファイルに google_cloud.json、local_env.yml を入れる

.gitignore

```
/config/local_env.yml
/config/google_cloud.json
```

## ローカル環境ファイルの読み込み設定のための記述を application.rb ファイルにする

config/application.rb

```
Bundler.require(*Rails.groups)

module GoogleTranslateApi01
  class Application < Rails::Application
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
  end
end
```

## translate コントローラー作成

```
$ rails g controller translate index
```

app/controllers/translate_controller.rb

```
class TranslateController < ApplicationController
    def index
        project_id = ENV["CLOUD_PROJECT_ID"]

        translate = Google::Cloud::Translate.new version: :v2, project_id: project_id

        @text = "Hello, world!"

        target = "ja"

        @translation = translate.translate @text, to: target
    end
end
```

## translate のルーティングとビューを作成

app/views/translate/index.html.erb

```
<h1>translate</h1>
<%= @text %>
<%= @translation %>
```

config/routes.rb

```
Rails.application.routes.draw do
  root "translate#index"
end
```

## ブラウザで確認

サーバーを立ち上げてちゃんと表示されるか確認してみましょう。

```
$ rails s
```

http://localhost:3000/

<img width="367" alt="スクリーンショット 2021-10-02 1 48 03" src="https://user-images.githubusercontent.com/66903388/135657868-d1dd4adc-c4b1-46ac-a2ba-4f77eaf6260d.png">
