# Todo の画面 (app/views/todos/) で使うヘルパー。
module TodosHelper
  # タイトル欄の最大文字数 (input の maxlength)。
  #
  # 上限は prisma/schema.prisma の `@ar.length` にだけ書き、ここでは生成されたモデルの
  # バリデーションから読む。スキーマを変えれば、画面の入力欄も同じ上限になる。
  #
  # @return [Integer, nil] 上限がないときは nil (maxlength を付けない)
  def todo_title_maxlength
    Todo.validators_on(:title).find { |validator| validator.kind == :length }&.options&.[](:maximum)
  end
end
