defmodule LogicTest do
  use ExSpec
  import Logic
  alias ZipperTree, as: Z

  describe "#prefix_to_bxt/1" do
    it "should convert from prefix to a binary expression tree" do
      result = prefix_to_bxt ["->", "v", "!", "A", "B", "v", "C", "D"]
      expected = Z.tree [ "->", ["v", ["!", "A"], "B"], ["v", "C", "D"] ]
      assert expected == result
    end
  end

  describe "#expand/1" do
    it "replaces implication with disjunction" do
      assert Z.tree ["v", ["!", "A"], "B"] == expand(Z.tree(["->", "A", "B"]))
    end

    it "recursively replaces implication with disjunctions" do
      assert Z.tree([ "v", ["!", ["v", ["!", "A"], "B"]], ["v", ["!", "C"], "D"]]) ==
        expand(Z.tree(["->", ["->", "A", "B"], ["->", "C", "D"]]))
    end

    it "replaces equivalence with conjunction" do
      assert Z.tree(["^", ["v", ["!", "A"], "B"], ["v", ["!", "B"], "A"]]) ==
        expand Z.tree(["<->", "A", "B"])
    end
  end
end
