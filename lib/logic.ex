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
  def expand [op, a, b] = t do
    # general strategy is to replace the current node with it's substitution
    # treating it's left and right nodes as indivual subtrees that require their
    # own expansion. Expanded subtrees are graphed back onto the substituted node
    case op do
      "->" ->
        ["v", expand(["!", a]), expand(b)]
      "<->" ->
        ["^", expand(["->", a, b]), expand(["->", b, a])]
      _ ->
        t
    end
  end

  def expand ["!", ["!", a]] do
    expand(a)
  end

  def expand ["!", a] do
    ["!", expand(a)]
  end

  def expand t do
    t
  end

  @doc """
  takes the binding list of varables and applies it to the formula, returns
  true if the binding is valid, false otherwise
  """
  def eval(f, binding) when is_list f do
    case f do
      [op, a] when is_function op ->
        op.(a)

      [op, a, b] when is_function op ->
        op.(a,b)

      ["!"] ->
        &Kernel.not/1

      ["^"] ->
        &Kernel.and/2

      ["v"] ->
        &Kernel.or/2

      [a] ->
        binding[String.to_atom a]

      _ when is_list f ->
        Enum.map(f, &eval(&1, binding))
        |> eval binding
    end
  end

  def eval(f, t) when is_binary f do
    f
    |> String.split
    |> prefix_to_bxt
    |> tap(f ~> f.loc)
    |> expand
    |> eval t
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

  def infix_to_prefix [], [], output do
    Enum.join output, " "
  end

  def infix_to_prefix [], [o|ops], output do
    infix_to_prefix [], ops, [o|output]
  end

  def infix_to_prefix ["("|tokens], ops, output do
    infix_to_prefix tokens, ["("|ops], output
  end

  def infix_to_prefix [")"|t1] = tokens, [o|ops], output do
    case o do
      "(" ->
        infix_to_prefix t1, ops, output
      _ ->
        infix_to_prefix tokens, ops, [o|output]
    end
  end

  def infix_to_prefix([t|t1] = tokens, ops, output) when t in @operators do
    case ops do
      [o|o1] when o in @operators ->
        infix_to_prefix tokens, o1, [o|output]
      _ ->
        infix_to_prefix t1, [t|ops], output
    end
  end

  def infix_to_prefix [t|t1], ops, output do
    infix_to_prefix t1, ops, [t|output]
  end

  def infix_to_prefix(f) when is_binary f do
    f |> String.split |> infix_to_prefix [], []
  end
end
