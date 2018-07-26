defmodule HelpCenter.UserTest do
  use HelpCenter.ModelCase

  alias HelpCenter.User

  @valid_attrs %{email: "some content", fb_id: "some content", is_active: true, phone: "some content", role: "some content", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
