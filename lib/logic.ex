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
  Recursively expands implications `-> A B` to `v ! A B` and
  exands implications of form `<-> A B` with `^ -> A B -> B A`
  """
  def expand %Loc{loc: [op, a, b] } = t do
    # general strategy is to replace the current node with it's substitution
    # treating it's left and right nodes as indivual subtrees that require their
    # own expansion. Expanded subtrees are graphed back onto the substituted node
    case op do
      "->" ->
        t |> change ["v", ["!", expand(tree a).loc], expand(tree b).loc]
      "<->" ->
        t |> change ["^", expand(tree ["->", a, b]).loc, expand(tree ["->", b, a]).loc]
    end
  end

  def expand %Loc{loc: ["!", a]} = t do
    t |> change ["!", expand(tree a).loc]
  end

  def expand t do
    t
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
