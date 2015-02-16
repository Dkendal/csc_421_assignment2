defmodule UnificationTest do
  use ExUnit.Case
  require Unification
  alias Unification, as: U

  test "matches rules to variables" do
    U.start_link :kb

    U.add_fact :kb, loves(dog(:fred), :fred)

    assert U.query(:kb, loves(x, x)) == [
      false
    ]

    U.add_fact :kb, loves(:sarah, :fred)
    U.add_fact :kb, loves(:fred, :sarah)
    U.add_fact :kb, loves(:fred, :fred)
    U.add_fact :kb, man(:fred)
    U.add_fact :kb, man(:joe)

    assert U.query(:kb, loves(x, y)) == [
      [x: ":fred", y: ":fred"],
      [x: ":fred", y: ":sarah"],
      [x: ":sarah", y: ":fred"],
      [x: "dog(:fred)", y: ":fred"],
      true
    ]

    assert U.query(:kb, loves(x, x)) == [
      [x: ":fred"],
      true
    ]

    assert U.query(:kb, loves(:sarah, :sarah)) == [false]

    assert U.query(:kb, loves(:fred, :fred)) == [true]

    assert U.query(:kb, loves(:fred, x)) == [
      [x: ":fred"],
      [x: ":sarah"],
      true
    ]

    assert U.query(:kb, loves(x, :sarah)) == [
      [x: ":fred"],
      true
    ]

    assert U.query(:kb, loves(dog(:fred), x)) == [
      [x: ":fred"],
      true
    ]

    assert U.query(:kb, man(x)) === [
      [x: ":joe"],
      [x: ":fred"],
      true
    ]

    assert U.query(:kb, loves(x, y, z)) == [false]
  end
end
