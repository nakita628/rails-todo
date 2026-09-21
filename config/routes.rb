Rails.application.routes.draw do
  # 言語を URL の先頭に入れる (/ja/..., /en/...)。省略したときは既定の日本語になる。
  # 対応していない言語 (/fr など) はどのルートにも一致せず 404 になる。
  scope "(:locale)", locale: /ja|en/ do
    root "todos#index"
    resources :todos, only: %i[create edit update destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
