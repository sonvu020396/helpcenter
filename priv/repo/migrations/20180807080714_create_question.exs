defmodule HelpCenter.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :image, :string
      add :contents, :string

      timestamps()
    end

  end
end
