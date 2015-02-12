defmodule Logic do
  import ZipperTree
  alias ZipperTree.Loc, as: Loc
  alias ZipperTree.Node, as: Node
  use PatternTap

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

  @binary_operators ["->", "<->", "v", "^"]
  @unary_operators ["!"]
  @operators @binary_operators ++ @unary_operators

  @doc """
  Expands implications `-> A B` to `v ! A B` and
  exands implications of form `<-> A B` with `^ -> A B -> B A`

  """

  def expand t do
    case t do
      %Loc{loc: "->"} ->
        change(t, "v")
        |> right
        |> tap(x ~> change x, ["!", expand(x)])
        |> right
        |> tap(x ~> change x, expand(x))
        |> top

      %Loc{loc: l} when is_binary l ->
        l

      %Loc{loc: l} when is_list l ->
        t
        |> down
        |> expand
    end
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
    top(r)
  end

  def prefix_to_bxt r, [h|t] do
    cond do
      # move up after completing a subtree
      subtree_complete? r ->
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

  defp subtree_complete? r do
    case r do
      %Loc{path: %Node{left: [o]}} -> o in @unary_operators
      %Loc{path: %Node{left: [_, o]}} -> o in @binary_operators
      _ -> false
    end
  end
end
