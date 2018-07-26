defmodule HelpCenter.User do
  use HelpCenter.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :phone, :string
    field :role, :string
    field :is_active, :boolean, default: false
    field :fb_id, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :phone, :role, :is_active, :fb_id])
    |> validate_required([:username, :email, :password, :phone, :role, :is_active, :fb_id])
  end
end
