source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# json 3 は JSON.parse の呼び方が変わり、Active Support 8.1 と合わない (暗号化 Cookie の読み込みで落ちる)
gem "json", "~> 2.21"
# Todo の ID は cuid2 (prisma/schema.prisma の `@default(cuid(2))`)。生成されるモデルが Cuid2.call を呼ぶ
gem "cuid2"
# Rails の標準メッセージ (バリデーション・日付・ボタンなど) の日本語訳 [https://github.com/svenfuchs/rails-i18n]
gem "rails-i18n"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # ソースコードのコメントから API ドキュメントを生成する [https://yardoc.org]
  gem "yard", require: false
  # YARD で Markdown (README.md の表やコードブロック) を表示する
  gem "redcarpet", require: false
  # `yard server` で使う Web サーバー (Ruby 3 から標準添付ではない)
  gem "webrick", require: false
end
