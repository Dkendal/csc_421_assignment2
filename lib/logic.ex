defmodule Logic do
  import ZipperTree
  alias ZipperTree.Loc, as: Loc
  alias ZipperTree.Node, as: Node

  @moduledoc """
  provides logic evaluations for a simple logical grammar
  EXPR = operator EXPR EXPR
  EXPR = terminal
  terminal = !?[A-Z]
  operator = "->" |
             "<->" |
             "v" |
             "^"
  """

  @operators ["->", "<->", "v", "^"]

  @doc """
  Expands implications `-> A B` to `v ! A B` and
  exands implications of form `<-> A B` with `^ -> A B -> B A`

  Expects a string in prefix notation.
  """

  def clausal ["->", a, b] do
    [ "v", [ "!", clausal(a) ], clausal(b) ]
  end

  def clausal [op, a, b] do
    [ op, clausal(a), clausal(b) ]
  end

  def clausal(a) do
    a
  end

  def expand str do
    str
    |> String.split
    |> prefix_to_bxt( [] )
  end

  @doc """
  initial condition: creates a root node containing the first symbol
  """
  def prefix_to_bxt [h|t] do
    %Loc{}
    |> insert_down(h)
    |> prefix_to_bxt t
  end

  @doc """
  returns the completed tree
  """
  def prefix_to_bxt r, [] do
    top(r).loc
  end

  def prefix_to_bxt r, [h|t] do
    cond do
      # move up after completing a subtree
      length(r.path.left) == 2 ->
        up(r)
        |> prefix_to_bxt [h|t]

      # create a new node for operators
      h in @operators ->
        insert_right(r, [h])
        |> right
        |> down
        |> prefix_to_bxt t

      # terminals
      true ->
        insert_right(r, h)
        |> right
        |> prefix_to_bxt t
    end
  end
end
