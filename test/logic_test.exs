defmodule LogicTest do
  use ExSpec
  describe "#prefix_to_bxt/1" do
    it "should convert from prefix to a binary expression tree" do
      result = Logic.prefix_to_bxt ["->", "v", "!", "A", "B", "v", "C", "D"]
      expected = ZipperTree.tree [ "->", ["v", ["!", "A"], "B"], ["v", "C", "D"] ]
      assert expected == result
    end
  end

  describe "#expand/1" do
    context "when input is a binary expression tree" do
      it "replaces implication with disjunction" do
        expected = ZipperTree.tree [ "v", ["!", "A"], "B" ]
        assert expected == Logic.expand ZipperTree.tree ["->", "A", "B"]
      end

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
