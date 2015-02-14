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

  #defp pop l, r \\ [] do
  #  Enum.slice l, 0, Enum.find_index(l, &("(" == &1)) || 1
  #end
  defp pop l, r \\ [] do
    case l do
      [] ->
        { r, [] }

      ["(" | t] ->
        { r, ["("|t] }

      [h|t] ->

        pop(t, r ++ [h])
    end
  end


  #While there are tokens to be read:
  #    Read a token.
  #    If the token is a number, then add it to the output queue.
  #    If the token is a function token, then push it onto the stack.
  #    If the token is a function argument separator (e.g., a comma):

  #        Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue. If no left parentheses are encountered, either the separator was misplaced or parentheses were mismatched.

  #    If the token is an operator, o1, then:

  #        while there is an operator token, o2, at the top of the stack, and either

  #            o1 is left-associative and its precedence is less than or equal to that of o2, or
  #            o1 if right associative, and has precedence less than that of o2,

  #        then pop o2 off the stack, onto the output queue;

  #        push o1 onto the stack.

  #    If the token is a left parenthesis, then push it onto the stack.
  #    If the token is a right parenthesis:

  #        Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue.
  #        Pop the left parenthesis from the stack, but not onto the output queue.
  #        If the token at the top of the stack is a function token, pop it onto the output queue.
  #        If the stack runs out without finding a left parenthesis, then there are mismatched parentheses.

  #When there are no more tokens to read:
  #    While there are still operator tokens in the stack:
  #        If the operator token on the top of the stack is a parenthesis, then there are mismatched parentheses.
  #        Pop the operator onto the output queue.
  #Exit.
  def infix_to_prefix [], [], output do
    Enum.join output, " "
  end

  def infix_to_prefix [], [o|ops], output do
    infix_to_prefix [], ops, [o|output]
  end

  def infix_to_prefix [t|t1] = tokens, ops, output do
    cond do
      t == "(" ->
        infix_to_prefix t1, [t|ops], output

      t == ")" ->
        case ops do
          [o|o1] when o in @operators ->
            infix_to_prefix tokens, o1, [o|output]

          ["("|o1] ->
            infix_to_prefix t1, o1, output
        end

      t in @operators ->
        case ops do
          [o|o1] when o in @operators ->
            infix_to_prefix tokens, o1, [o|output]

          _ ->
            infix_to_prefix t1, [t|ops], output
        end

      true ->
        infix_to_prefix t1, ops, [t|output]
    end
  end

  def infix_to_prefix(f) when is_binary f do
    f |> String.split |> infix_to_prefix [], []
  end
end
