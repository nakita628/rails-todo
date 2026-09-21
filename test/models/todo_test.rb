require "test_helper"

# Todo モデルのテスト。
#
# モデルは hekireki が prisma/schema.prisma から生成するので、ここではスキーマに書いた
# 制約 (既定値・ID の採番・バリデーション) と、生成された翻訳が Rails 側で効いていることを確かめる。
class TodoTest < ActiveSupport::TestCase
  test "作成時は未完了になる" do
    # スキーマの @default(false) が、保存前のモデルにも入っていること
    assert_not Todo.new(title: "犬の散歩").completed?
  end

  test "保存前に cuid2 の ID が採番される" do
    # @default(cuid(2)) に合わせて、Rails 側でも英小文字で始まる 24 文字の ID を作る
    assert_match(/\A[a-z][a-z0-9]{23}\z/, Todo.new.id)
  end

  test "タイトルは必須" do
    todo = Todo.new(title: "")

    assert_not todo.valid?
    # どのルールで弾かれたかは、言語に依存しない of_kind? で確かめる
    assert todo.errors.of_kind?(:title, :blank)
  end

  test "タイトルは 140 文字まで" do
    assert Todo.new(title: "あ" * 140).valid?

    todo = Todo.new(title: "あ" * 141)
    assert_not todo.valid?
    assert todo.errors.of_kind?(:title, :too_long)
  end

  test "前後の空白は保存前に取り除く" do
    # スキーマの `@ar.normalizes` から生成された normalizes
    assert_equal "犬の散歩", Todo.new(title: "  犬の散歩\n").title
  end

  test "空白だけのタイトルは空として扱う" do
    todo = Todo.new(title: "   ")

    assert_not todo.valid?
    assert todo.errors.of_kind?(:title, :blank)
  end

  test "文字数は空白を取り除いた後で数える" do
    assert Todo.new(title: " #{"あ" * 140} ").valid?
  end

  test "recent は新しい順に並べる" do
    # スキーマの `@ar.scope :recent` から生成された scope。fixtures には created_at を書いていないので、ここで作る
    older = Todo.create!(title: "先に作った", created_at: 2.days.ago)
    newer = Todo.create!(title: "後で作った", created_at: 1.day.ago)

    assert_equal [ newer, older ], Todo.recent.where(id: [ older.id, newer.id ]).to_a
  end

  # バリデーションメッセージ。
  # 項目名とメッセージは hekireki が生成する config/locales/models/todo/<言語>.yml から、
  # 項目名とメッセージのつなぎ方 (errors.format) は rails-i18n から来る。
  # 日本語は「タイトル」と「を入力してください」の間に空白を入れない。

  test "日本語: 空のタイトル" do
    assert_equal [ "タイトルを入力してください" ], full_messages(title: "")
  end

  test "日本語: 長すぎるタイトル" do
    assert_equal [ "タイトルは140文字以内で入力してください" ], full_messages(title: "あ" * 141)
  end

  test "英語: 空のタイトル" do
    assert_equal [ "Title can't be blank" ], full_messages(title: "", locale: :en)
  end

  test "英語: 長すぎるタイトル" do
    # too_long は one / other を持ち、I18n が count (= 140) で other を選ぶ
    assert_equal [ "Title is too long (maximum is 140 characters)" ], full_messages(title: "a" * 141, locale: :en)
  end

  test "英語: 上限が 1 文字なら単数形の文言になる" do
    # 上限 140 では使われない one の文言も、I18n が count で選べる形で入っていること
    message = I18n.t("activerecord.errors.models.todo.attributes.title.too_long", count: 1, locale: :en)

    assert_equal "is too long (maximum is 1 character)", message
  end

  private

  # 指定した言語で検証し、画面に出るのと同じ形のエラーメッセージを返す。
  #
  # @param title [String]
  # @param locale [Symbol]
  # @return [Array<String>]
  def full_messages(title:, locale: I18n.default_locale)
    I18n.with_locale(locale) do
      todo = Todo.new(title:)
      todo.valid?
      todo.errors.full_messages
    end
  end
end
