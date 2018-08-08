defmodule HelpCenter.QuestionTest do
  use HelpCenter.ModelCase

  alias HelpCenter.Question

  @valid_attrs %{contents: "some content", image: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Question.changeset(%Question{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Question.changeset(%Question{}, @invalid_attrs)
    refute changeset.valid?
  end
end
