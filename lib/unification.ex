defmodule Unification do
  alias Unification, as: U

  def start_link name do
    Agent.start_link fn -> %{} end, name: name
  end

  defmacro add_fact agent, {key, _, args } do
    args = for val <- args, do: (Macro.to_string val)

    quote do
      U.set unquote(agent), unquote(key), unquote(args)
    end
  end

  defmacro query agent, {key, _, args} do
    # escape all values except unbound variables
    args = for val <- args do
      case val do
        {_variable_name, _context, nil} -> val
        _ -> Macro.to_string val
      end
    end

    quote do
      facts = Agent.get unquote(agent), fn f -> f[unquote(key)] end
      matches = for m <- facts do
        try do
          # attempt to bind the variable
          unquote(args) = m
          {:ok, binding }
        rescue
          _ in MatchError ->
            {:error, "no match"}
        end
      end

      has_matches = Enum.any? matches, fn
        {:ok, _} -> true
        _ -> false
      end

      result = for {:ok, m} <- matches, m != [], do: m

      result ++ [has_matches]
    end
  end

  def set agent, key, fact do
    Agent.update agent, fn( kb ) ->
      Dict.update kb, key, [ fact ], fn old ->
        [fact|old]
      end
    end
  end
end
