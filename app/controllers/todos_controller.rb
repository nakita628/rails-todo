# Todo の一覧・追加・編集・削除を扱うコントローラ。
#
# 成功したらトップページ (`/`) にリダイレクトし、失敗したら 422 で画面を描き直す、
# Rails の標準的な CRUD の形にしている。画面の部分更新は Turbo が行うので、
# コントローラ側で Turbo 専用の処理は書かない。
#
# 並び順などのデータの扱いはモデル (Todo.recent) に置き、コントローラはそれを呼ぶだけにする。
class TodosController < ApplicationController
  before_action :set_todo, only: %i[edit update destroy]

  # 一覧と、追加用の空のフォームを表示する。
  #
  # GET /
  def index
    @todos = Todo.recent
    @todo = Todo.new
  end

  # Todo を追加する。
  #
  # 入力が正しくなければ、エラーを付けて一覧を 422 で描き直す。
  #
  # POST /todos
  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      redirect_to root_path, notice: t(".notice")
    else
      @todos = Todo.recent
      render :index, status: :unprocessable_content
    end
  end

  # 編集画面を表示する。
  #
  # GET /todos/:id/edit
  def edit
  end

  # Todo を更新する。タイトルの編集と、完了・未完了の切り替えの両方に使う。
  #
  # PATCH /todos/:id
  def update
    if @todo.update(todo_params)
      redirect_to root_path, notice: t(".notice")
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Todo を削除する。
  #
  # DELETE 後のリダイレクトは 303 (See Other) にする。
  # 302 だとブラウザが DELETE のままリダイレクト先を読みに行くことがあるため。
  #
  # DELETE /todos/:id
  def destroy
    @todo.destroy!
    redirect_to root_path, notice: t(".notice"), status: :see_other
  end

  private

  # URL の `:id` から対象の Todo を読み込む。
  #
  # @return [Todo]
  # @raise [ActiveRecord::RecordNotFound] 見つからないとき (404 になる)
  def set_todo
    @todo = Todo.find(params.expect(:id))
  end

  # フォームから受け取ってよい項目だけを取り出す (Strong Parameters)。
  #
  # @return [ActionController::Parameters] `title` と `completed`
  def todo_params
    params.expect(todo: %i[title completed])
  end
end
