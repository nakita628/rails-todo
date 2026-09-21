require "test_helper"

# TodosController のテスト。
#
# 一覧・追加・編集・完了切り替え・削除を、HTTP リクエストとして送って確かめる。
# Turbo による画面の部分更新はブラウザ側の動きなので、ここでは対象にしない。
class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    # アプリの ApplicationController#default_url_options と同じく、URL に言語 (/ja/...) を入れる。
    # 入れないと todo_url(@todo) の @todo が、URL の先頭の :locale に当てはめられてしまう
    self.default_url_options = { locale: I18n.default_locale }
    @todo = todos(:buy_milk)
  end

  test "一覧を表示できる" do
    get root_url

    assert_response :success
    assert_select "li", text: /牛乳を買う/
  end

  test "URL に言語がなければ、日本語で表示する" do
    get "/"

    assert_select "h1", "やること"
  end

  test "URL の言語が英語なら、画面も英語になる" do
    get root_url(locale: :en)

    assert_select "h1", "Todos"
  end

  test "対応していない言語の URL は 404 になる" do
    get "/fr"

    assert_response :not_found
  end

  test "英語の画面で追加すると、英語の一覧に戻る" do
    post todos_url(locale: :en), params: { todo: { title: "Walk the dog" } }

    assert_redirected_to root_url(locale: :en)
  end

  test "Todo を追加できる" do
    assert_difference("Todo.count") do
      post todos_url, params: { todo: { title: "犬の散歩" } }
    end

    assert_redirected_to root_url
    # 追加した直後は未完了。ID は作成順に並ばないので、タイトルで探す
    assert_not Todo.find_by!(title: "犬の散歩").completed?
  end

  test "タイトルが空だと追加できず、422 で一覧を描き直す" do
    assert_no_difference("Todo.count") do
      post todos_url, params: { todo: { title: "" } }
    end

    # 422 を返すことで、Turbo がエラー付きの画面を表示する
    assert_response :unprocessable_content
    assert_select "[role=alert]", /タイトルを入力してください/
  end

  test "タイトルが 140 文字を超えると追加できない" do
    assert_no_difference("Todo.count") do
      post todos_url, params: { todo: { title: "あ" * 141 } }
    end

    assert_response :unprocessable_content
    assert_select "[role=alert]", /タイトルは140文字以内で入力してください/
  end

  test "英語の画面では、エラーメッセージも英語になる" do
    post todos_url(locale: :en), params: { todo: { title: "" } }

    assert_response :unprocessable_content
    assert_select "[role=alert] li", "Title can't be blank"
  end

  test "タイトルの前後の空白は取り除いて保存する" do
    post todos_url, params: { todo: { title: "  犬の散歩  " } }

    assert Todo.exists?(title: "犬の散歩")
  end

  test "未完了の件数を表示する" do
    # fixtures は未完了 1 件 (牛乳を買う)、完了 1 件 (レポートを書く)
    get root_url

    assert_select "#remaining", "残り 1 件"
  end

  test "英語では未完了の件数で単数・複数を選ぶ" do
    get root_url(locale: :en)
    assert_select "#remaining", "1 item left"

    Todo.create!(title: "Walk the dog")
    get root_url(locale: :en)
    assert_select "#remaining", "2 items left"
  end

  test "編集画面を表示できる" do
    get edit_todo_url(@todo)

    assert_response :success
  end

  test "タイトルを更新できる" do
    patch todo_url(@todo), params: { todo: { title: "豆乳を買う" } }

    assert_redirected_to root_url
    assert_equal "豆乳を買う", @todo.reload.title
  end

  test "完了に切り替えられる" do
    # 一覧の「Done」ボタンと同じリクエスト
    patch todo_url(@todo), params: { todo: { completed: true } }

    assert @todo.reload.completed?
  end

  test "タイトルを空にすると更新できず、422 で編集画面を描き直す" do
    patch todo_url(@todo), params: { todo: { title: "" } }

    assert_response :unprocessable_content
  end

  test "Todo を削除できる" do
    assert_difference("Todo.count", -1) do
      delete todo_url(@todo)
    end

    # DELETE の後は 303 でリダイレクトする
    assert_response :see_other
    assert_redirected_to root_url
  end
end
