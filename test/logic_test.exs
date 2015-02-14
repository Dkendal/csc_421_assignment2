defmodule LogicTest do
  use ExSpec
  import Logic
  alias ZipperTree, as: Z

  describe "infix_to_prefix/2"  do
    it "should handle binary operators properly" do
      assert "-> B A" == infix_to_prefix "A -> B"
      assert "v B A" == infix_to_prefix "A v B"
      assert "^ B A" == infix_to_prefix "A ^ B"
      assert "<-> B A" == infix_to_prefix "A <-> B"
    end

    it "should handle unary operators properly" do
      assert "! A" == infix_to_prefix "! A"
      assert "-> B ! A" == infix_to_prefix "! A -> B"
    end

    it "should handle parens" do
      assert "-> v C B A" == infix_to_prefix "A -> ( B v C )"
    end
  end

  describe "prefix_to_bxt/1" do
    it "should convert from prefix to a binary expression tree" do
      result = prefix_to_bxt ["->", "v", "!", "A", "B", "v", "C", "D"]
      expected = Z.tree [ "->", ["v", ["!", "A"], "B"], ["v", "C", "D"] ]
      assert expected == result
    end
  end

  describe "expand/1" do
    it "replaces implication with disjunction" do
      assert ["v", ["!", "A"], "B"] == expand(["->", "A", "B"])
    end

    it "simplifies double negation" do
      assert "A" == expand(["!", ["!", "A"]])
    end

    it "recursively replaces implication with disjunctions" do
      assert [ "v", ["!", ["v", ["!", "A"], "B"]], ["v", ["!", "C"], "D"]] ==
        expand(["->", ["->", "A", "B"], ["->", "C", "D"]])
    end

    it "replaces equivalence with conjunction" do
      assert ["^", ["v", ["!", "A"], "B"], ["v", ["!", "B"], "A"]] ==
        expand ["<->", "A", "B"]
    end
  end

  describe "eval/2" do
    it "evaluates whether the assignment is valid" do
      assert eval("^ A B", A: true, B: true) == true
      assert eval("^ A B", A: true, B: false) == false
      assert eval("^ A B", A: false, B: true) == false
      assert eval("^ A B", A: false, B: false) == false

      assert eval("v A B", A: true, B: true) == true
      assert eval("v A B", A: false, B: true) == true
      assert eval("v A B", A: true, B: false) == true
      assert eval("v A B", A: false, B: false) == false

      assert eval("A", A: true) == true
      assert eval("A", A: false) == false
      assert eval("! A", A: false) == true
      assert eval("! A", A: true) == false

      assert eval("-> A B", A: true, B: true) == true
      assert eval("-> A B", A: true, B: false) == false
      assert eval("-> A B", A: false, B: true) == true
      assert eval("-> A B", A: false, B: false) == true

      assert eval("<-> A B", A: true, B: true) == true
      assert eval("<-> A B", A: true, B: false) == false
      assert eval("<-> A B", A: false, B: true) == false
      assert eval("<-> A B", A: false, B: false) == true
    end
  end
end
