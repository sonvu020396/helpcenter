defmodule HelpCenter.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string
      add :email, :string
      add :phone, :string
      add :role, :string
      add :is_active, :boolean, default: true, null: false
      add :fb_id, :string

      timestamps()
    end
  end

  alter table(:users) do
    add :password, :string
  end
end
