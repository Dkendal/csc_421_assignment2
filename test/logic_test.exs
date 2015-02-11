defmodule LogicTest do
  use ExSpec
  describe "#prefix_to_bxt" do
    it "should convert from prefix to a binary expression tree" do
      tree = Logic.prefix_to_bxt String.split "-> v !A B v C D"
      assert tree == [ "->", ["v", "!A", "B"], ["v", "C", "D"] ]
    end
  end
  #test "converts implication a simple implication to disjunction" do
  #  # !A v B = A -> B
  #  assert "v!AB" == expand "-> A B"
  #end

  #test "converts when there's an op on first arg" do
  #  assert "v!BvAC" == expand "-> B v A C"
  #end

  #test "converts when there's an op on the second arg" do
  #  assert "v!vACB" == expand "-> v A C B"
  #end
end
