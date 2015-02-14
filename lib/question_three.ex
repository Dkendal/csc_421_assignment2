import Logic

defmodule Mix.Tasks.Question.Three do
  use Mix.Task
  defmacro log {:eval, _, [{f, _, _}, {b, _, _}]} = t do
    quote do
      IO.puts "formula #{ unquote(f) } under binding #{ unquote(b) } is #{ unquote(t) }"
    end
  end

  def run _ do
    #(( p 1 ->  ( p 2 ^ p 3)) ^ (( ! p 1) ->  ( p 3 ^ p 4)))
    a  = "^ -> p1 ^ p2 p3 -> ! p1 ^ p3 p4"
    #(( p 3 ->  ( ! p 6)) ^ (( ! p 3) ->  ( p 4 ->  p 1)))
    b = "^ -> p3 ! p6 -> ! p3 -> p4 p1"
    #(( ! ( p 2 ^ p 5)) ^ ( p 2 ->  p 5))
    c = "^ ! ^ p2 p5 -> p2 p5"
    #( ! ( p 3 ->  p 6))
    d = "! -> p3 p6"
    #(( A ^ ( B ^ C)) ->  D)
    e = "-> ^ A ^ B C D"

    i1 = [p1: false,
      p3: false,
      p5: false,
      p2: true,
      p4: true,
      p6: true]

    i2 = [p1: true,
      p3: true,
      p5: true,
      p2: false,
      p4: false,
      p6: false]

    e_under_i1 = eval(e, A: eval(a, i1),
                         B: eval(b, i1),
                         C: eval(c, i1),
                         D: eval(d, i1))

    e_under_i2 = eval(e, A: eval(a, i2),
                         B: eval(b, i2),
                         C: eval(c, i2),
                         D: eval(d, i2))

    log eval(a, i1)
    log eval(b, i1)
    log eval(c, i1)
    log eval(d, i1)
    IO.puts "formula e under binding i1 is #{e_under_i1}"

    log eval(a, i2)
    log eval(b, i2)
    log eval(c, i2)
    log eval(d, i2)
    IO.puts "formula e under binding i2 is #{e_under_i2}"
  end
end
