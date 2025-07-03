# Box2You - AI Book Summary Platform

## 📘 概要
Box2YouはAI要約機能を備えた本の検索・発見プラットフォームです。ユーザーは本のタイトルで検索し、ChatGPT等のAIが生成した500文字程度の要約を確認することで、読む価値があるかを素早く判断できます。また、Amazon Product Advertising APIを使用したAmazon商品検索機能も搭載しています。

## 🎯 主な機能

### ✨ 既に実装済みの機能
- **検索機能**: 本のタイトルに対するインクリメンタル検索（pg_search + PostgreSQL full-text search）
- **AI要約生成**: OpenAI APIを使用したインテリジェントな書籍要約
- **Amazon商品検索**: vacuum gemを使用したAmazon Product Advertising API連携
- **多言語対応**: `books` + `book_translations` テーブル構成（現在は英語のみ）
- **レスポンシブUI**: Tailwind CSSを使用したモダンなデザイン
- **Typed.js演出**: トップページでのAI風アニメーション効果
- **リアルタイム検索**: Stimulus controllerによるライブ検索機能
- **アフィリエイトリンク**: Amazon・Rakutenへの購入リンク（プレースホルダー）

### 📋 サンプルデータ
以下の人気書籍のデータとAI要約が含まれています：
- Atomic Habits (James Clear)
- The 7 Habits of Highly Effective People (Stephen R. Covey)
- Sapiens: A Brief History of Humankind (Yuval Noah Harari)
- Rich Dad Poor Dad (Robert T. Kiyosaki)
- The Lean Startup (Eric Ries)
- Deep Work (Cal Newport)
- Thinking, Fast and Slow (Daniel Kahneman)
- The Power of Habit (Charles Duhigg)

## 🛠️ 技術スタック

### バックエンド
- **Ruby on Rails 8.0.2**
- **PostgreSQL** (pg_search + tsvector、full-text search)
- **OpenAI API** (ruby-openai gem使用)
- **Amazon Product Advertising API** (vacuum gem使用)

### フロントエンド
- **Importmap + Turbo + Stimulus** (Rails標準)
- **Tailwind CSS** (responsive design)
- **Typed.js** (アニメーション効果)

### デプロイ想定
- **Render.com** (サーバーホスティング)
- **Cloudflare** (ドメイン管理 + CDN + キャッシュ)

## 🚀 セットアップ手順

### 1. 依存関係のインストール
```bash
bundle install
```

### 2. データベースセットアップ
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 3. OpenAI API キーの設定
```bash
# 方法1: 環境変数で設定
export OPENAI_API_KEY="your_openai_api_key_here"

# 方法2: Rails credentialsで設定
bin/rails credentials:edit
# 以下を追加:
# openai:
#   api_key: your_openai_api_key_here
```

### 4. Amazon Product Advertising API キーの設定（オプション）
Amazon商品検索機能を使用する場合は、以下の設定が必要です：

```bash
# Rails credentialsで設定
bin/rails credentials:edit

# 以下を追加:
# amazon:
#   access_key: YOUR_ACCESS_KEY
#   secret_key: YOUR_SECRET_KEY
#   associate_tag: YOUR_ASSOCIATE_TAG
#   marketplace: JP  # or US, UK, etc.
```

**注意**: Amazon PA-APIを使用するには：
1. [Amazon Associatesプログラム](https://affiliate.amazon.co.jp/)に登録
2. PA-APIのアクセス権を申請
3. 180日以内に3件の売上が必要（継続利用のため）

設定しない場合、Amazon商品検索機能は無効になりますが、他の機能は正常に動作します。

### 5. アプリケーション起動
```bash
# Tailwind CSSをビルド
bin/rails tailwindcss:build

# サーバー起動
bin/dev
# または
bundle exec rails server
```

## 📂 主要ファイル構造

```
app/
├── controllers/
│   ├── home_controller.rb              # トップページ
│   ├── books_controller.rb             # 書籍一覧・詳細・検索
│   └── amazon_products_controller.rb   # Amazon商品検索
├── models/
│   ├── book.rb                         # 書籍モデル（AI要約生成機能含む）
│   └── book_translation.rb             # 翻訳モデル（pg_search設定）
├── services/
│   └── amazon_product_service.rb       # Amazon API連携サービス
├── views/
│   ├── home/index.html.erb             # LP風トップページ
│   ├── books/show.html.erb             # 書籍詳細ページ
│   ├── books/search.html.erb           # 検索結果ページ
│   └── amazon_products/                # Amazon商品検索UI
│       ├── index.html.erb              # 検索・一覧ページ
│       └── show.html.erb               # 商品詳細ページ
├── javascript/controllers/
│   ├── typed_controller.js             # Typed.js制御
│   └── search_controller.js            # リアルタイム検索
└── config/initializers/
    └── amazon_paapi.rb                 # Amazon API設定
```

## 🔧 データベース設計

### Books テーブル
- `isbn` (string, unique): 書籍のISBN
- `popularity_score` (integer): 人気度スコア
- `ai_summary_cached` (boolean): AI要約済みフラグ

### BookTranslations テーブル
- `book_id` (references): 書籍への外部キー
- `title` (string): 書籍タイトル
- `author` (string): 著者名
- `summary` (text): AI生成要約
- `language` (string): 言語コード（現在は'en'のみ）

## 🚀 今後の拡張予定

### Phase 2 機能
- [ ] 日本語対応
- [ ] ユーザー登録・ログイン機能
- [ ] お気に入り・読了管理
- [ ] レビュー・評価機能
- [ ] カテゴリ・ジャンル分類

### Phase 3 機能
- [ ] APIエンドポイント提供
- [ ] 外部書籍データベース連携
- [ ] 推薦アルゴリズム
- [ ] ソーシャル機能（シェア・フォロー）

## 🌐 デプロイ設定

### Render.com用設定
- PostgreSQLアドオン必要
- 環境変数: `OPENAI_API_KEY`
- Buildpack: Ruby

### Cloudflare設定
- Page Rules for caching
- Security settings
- DNS management

## 📝 開発者向け情報

### コミット規則
```bash
git commit -m "feat: 新機能追加"
git commit -m "fix: バグ修正"
git commit -m "docs: ドキュメント更新"
git commit -m "style: コードフォーマット"
```

### テスト実行
```bash
# 今後追加予定
bin/rails test
```

## 📄 ライセンス
このプロジェクトはMITライセンスの下で公開されています。

## 🤝 コントリビューション
プルリクエストや Issues は歓迎します！

---

**Box2You** - AI-powered book summaries to help you discover your next great read. 📚✨
