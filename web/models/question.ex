defmodule HelpCenter.Question do
  use HelpCenter.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "questions" do
    field :title, :string
    field :image, :string
    field :contents, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :image, :contents])
    |> validate_required([:title, :image, :contents])
  end
end
