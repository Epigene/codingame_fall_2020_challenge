# frozen_string_literal: true

# rspec spec/game_turn_spec.rb
RSpec.describe GameTurn do
  let(:instance) { described_class.new(**options) }
  let(:options) { {actions: actions, me: me, opp: opp} }
  let(:actions) { {} }
  let(:me) { {} }
  let(:opp) { {} }

  # v1
  describe "#move" do
    subject(:move) { instance.move }

    context "when initialized with reference state 1" do
      let(:actions) do
        {
          44 => {type: "BREW", delta0: 0, delta1:-2, delta2:0, delta3:0, :price=>8},
          42 => {type: "BREW", delta0: -1, delta1:-1, delta2:0, delta3:0, :price=>6},
          61 => {type: "BREW", delta0: 0, delta1:0, delta2:0, delta3:-2, :price=>16},
          50 => {type: "BREW", delta0: -1, delta1:0, delta2:0, delta3:-1, :price=>10},
          54 => {type: "BREW", delta0: 0, delta1:-1, delta2:0, delta3:-1, :price=>12}
        }
      end

      context "when I have enough ingredients for the most lucrative potion" do
        let(:me) { {inv: [2, 2, 3, 3]} }

        it "moves to brew the best potion" do
          is_expected.to include("BREW 61")
        end
      end

      context "when I dont have enough resources for the most lucrative potion, but do for the second" do
        let(:me) { {inv: [2, 2, 3, 1]} }

        it "moves to brew the second best" do
          is_expected.to include("BREW 54")
        end
      end
    end

    context "when there's spells to learn, but they're all degenerators" do
      let(:me) { {inv: [3, 2, 0, 0], turn: 3} }

      let(:actions) do
        {
          11 => {type:"LEARN", delta0: 2, delta1:2, delta2:-1, delta3:0, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
          10 => {type:"LEARN", delta0: 4, delta1:-1, delta2:0, delta3:0, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
          44 => {type: "BREW", delta0: 0, delta1:-2, delta2:0, delta3:0, :price=>8},
        }
      end

      before { allow(instance).to receive(:simplest_potion_id).and_return(44) }

      it "skips learning, opting to get to brewing instead" do
        is_expected.to include("BREW 44")
      end
    end

    context "when there's pure giver spell to learn and it's early in the game" do
      let(:me) { {inv: [3, 2, 0, 0], turn: 3} }

      let(:actions) do
        {
          11 => {type:"LEARN", delta0: 0, delta1:-2, delta2:2, delta3:0, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
          10 => {type:"LEARN", delta0: 2, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true}
        }
      end

      it "returns the move to learn the pure giver spell" do
        is_expected.to include("LEARN 10")
      end
    end

    context "when there's a regular transmuter to learn and it's early in the game" do
      let(:me) { {inv: [3, 2, 0, 0], turn: 3} }

      let(:actions) do
        {
          11 => {type:"LEARN", delta0: 0, delta1:-2, delta2:2, delta3:0, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
          10 => {type:"LEARN", delta0: 3, delta1:-2, delta2:0, delta3:0, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true}
        }
      end

      it "returns the move to learn the first spell" do
        is_expected.to include("LEARN 11")
      end
    end

    context "when there's a simple potion and we should work towards it" do
      let(:actions) do
        {
          76 => {type:"BREW", delta0: -1, delta1:-1, delta2:-3, delta3:-1, :price=>18, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          70 => {type:"BREW", delta0: -1, delta1:-1, delta2:0, delta3:-1, :price=>15, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          1 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          2 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          3 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          4 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
        }
      end

      let(:me) { {inv: [3, 0, 0, 0], turn: 51} }

      it "returns the move to transmute to green" do
        is_expected.to include("CAST 2")
      end
    end

    context "when I've just made a green one and should just rest to get another" do
      let(:me) { {inv: [2, 1, 1, 1], turn: 51} }

      let(:actions) do
        {
          53 => {type:"BREW", delta0: 0, delta1:0, delta2:-4, delta3:0, :price=>15, :tome_index=>3, :tax_count=>3, :castable=>false, :repeatable=>false},
          58 => {type:"BREW", delta0: 0, delta1:-3, delta2:0, delta3:-2, :price=>15, :tome_index=>1, :tax_count=>3, :castable=>false, :repeatable=>false},
          70 => {type:"BREW", delta0: -2, delta1:-2, delta2:0, delta3:-2, :price=>15, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          67 => {type:"BREW", delta0: 0, delta1:-2, delta2:-1, delta3:-1, :price=>12, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          77 => {type:"BREW", delta0: -1, delta1:-1, delta2:-1, delta3:-3, :price=>20, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
          80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
        }
      end

      it "returns a move to just rest to make another green" do
        is_expected.to include("REST")
      end
    end

    context "when we've a bunch of spells" do
      let(:me) { {inv: [6, 2, 1, 0], turn: 51} } # total of 9

      let(:actions) do
        {
          79 => {type:"CAST", delta0: 4, delta1:1, delta2:-1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          2 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          3 => {type:"CAST", delta0: 0, delta1:2, delta2:-1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          44 => {type:"BREW", delta0: 0, delta1:-5, delta2:0, delta3:0, :price=>15, :tome_index=>-1, :tax_count=>0, :castable=>false, :repeatable=>false},
        }
      end

      before do
        allow(instance).to receive(:simplest_potion_id).and_return(44)
      end

      it "returns a move that casts a valid spell (as opposed to one that overfills inventory)" do
        is_expected.to include("CAST 2")
      end
    end
  end

  describe "#move_v2" do
    subject(:move) { instance.move_v2 }

    before(:all) do
      TestProf::StackProf.run
    end

    context "when the situation is such that the leftmost potion is easy to make" do
      let(:actions) do
        {
          60 => {:type=>"BREW", :delta0=>0, :delta1=>0, :delta2=>-5, :delta3=>0, :price=>18, :tome_index=>3, :tax_count=>4, :castable=>false, :repeatable=>false},
          68 => {:type=>"BREW", :delta0=>-1, :delta1=>0, :delta2=>-2, :delta3=>-1, :price=>13, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
          48 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-2, :delta3=>0, :price=>10, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          56 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-3, :delta3=>0, :price=>13, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          51 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>-3, :delta3=>0, :price=>11, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          36 => {:type=>"LEARN", :delta0=>0, :delta1=>-3, :delta2=>3, :delta3=>0, :tome_index=>0, :tax_count=>0},
          31 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>2, :delta3=>-2, :tome_index=>1, :tax_count=>0},
          34 => {:type=>"LEARN", :delta0=>-2, :delta1=>0, :delta2=>-1, :delta3=>2, :tome_index=>2, :tax_count=>0},
          16 => {:type=>"LEARN", :delta0=>1, :delta1=>0, :delta2=>1, :delta3=>0, :tome_index=>3, :tax_count=>0},
          1 => {:type=>"LEARN", :delta0=>3, :delta1=>-1, :delta2=>0, :delta3=>0, :tome_index=>4, :tax_count=>0},
          22 => {:type=>"LEARN", :delta0=>0, :delta1=>2, :delta2=>-2, :delta3=>1, :tome_index=>5, :tax_count=>0},
          78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
        }
      end

      let(:me) { {:inv=>[3, 0, 0, 0], :score=>0, turn: 1, previous_move: ""} }

      it "returns the first step towards easy brewin of leftmost potion" do
        is_expected.to eq(
          "LEARN 16 let's brew 60 via [LEARN 16, CAST 82, REST, CAST 82, REST, CAST 82]"
        )
      end
    end
  end

  describe "array vs hash dup" do
    before(:all) do
      TestProf::StackProf.run
    end

    it "compares time it takes to dup array vs a hash 40k times" do
      hash = {type:"CAST", delta0: 4, delta1:1, delta2:-1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
      array = ["CAST", 4, 1, -1, 0, 0, -1, -1, true, false]

      array_time = Benchmark.realtime do
        40_000.times do
          array.dup
        end
      end

      puts("Array time: #{ array_time }")

      hash_time = Benchmark.realtime do
        40_000.times do
          hash.dup
        end
      end

      puts("Hash time: #{ hash_time }")

      expect(1).to eq(1)
    end
  end

  #== Privates ==

  describe "#cost_in_moves(potion)" do
    subject(:cost_in_moves) { instance.send(:cost_in_moves, potion) }

    context "when potion requires one of each resource" do
      let(:potion) { {delta0: -1, delta1:-1, delta2:-1, delta3:-1, price: 9} }

      it { is_expected.to eq(16) }
    end

    context "when potion requires two green and three orange" do
      let(:potion) { {delta0: 0, delta1:-2, delta2:-3, delta3:0} }

      it { is_expected.to eq(21) }
    end
  end

  describe "#next_step_towards(target_inventory)" do
    subject(:next_step_towards) do
      instance.send(:next_step_towards, target_inventory)
    end

    let(:actions) do
      {
        1 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, :castable=>true, :repeatable=>false},
        2 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, :castable=>true, :repeatable=>false},
        3 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, :castable=>true, :repeatable=>false},
        4 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, :castable=>true, :repeatable=>false}
      }
    end

    let(:me) { {inv: []} }

    context "when lacking a yellow" do
      let(:target_inventory) { [0, 0, 0, 1] }

      context "when spell is available and orange is available" do
        let(:me) { {inv: [0, 0, 1, 0]} }

        it "returns the move to cast orange->yellow spell" do
          is_expected.to include("CAST 4")
        end
      end

      context "when I know several spells to transmute to yellow" do
        let(:actions) do
          s = super()
          s[4][:castable] = false
          s[5] = {type:"CAST", delta0: 0, delta1:-1, delta2:0, delta3:1, :castable=>true, :repeatable=>false}
          s
        end

        let(:me) { {inv: [0, 1, 0, 0]} }

        it "returns the move to cast the available spell" do
          is_expected.to include("CAST 5")
        end
      end

      context "when yellow can not be created due to orange missing but orange can be created" do
        let(:me) { {inv: [0, 1, 0, 0]} }

        let(:actions) { super().tap{ |a| a[4][:castable] = false } }

        it "returns the move to cast green->orange spell" do
          is_expected.to include("CAST 3")
        end
      end

      context "when yellow can not be created due to orange missing and green missing, but green can be made" do
        let(:me) { {inv: [1, 0, 0, 0]} }

        it "returns the move to cast blue->green spell" do
          is_expected.to include("CAST 2")
        end
      end

      context "when yellow can not be created due to everything missing" do
        let(:me) { {inv: [0, 0, 0, 0]} }

        it "returns the move to cast blue++" do
          is_expected.to include("CAST 1")
        end
      end

      context "when nothing can be cast" do
        let(:actions) { super().tap{ |s| s[1][:castable] = false } }
        let(:me) { {inv: [0, 0, 0, 0]} }

        it "returns the move to REST" do
          is_expected.to include("REST")
        end
      end
    end
  end

  describe "#i_can_cast?(spell)" do
    subject(:i_can_cast?) { instance.send(:i_can_cast?, spell) }

    let(:spell) { {delta0: -1, delta1:1, delta2:0, delta3:0, :castable=>true} }

    context "when the spell would overfill inventory" do
      let(:spell) { {delta0: 1, delta1:0, delta2:0, delta3:0, :castable=>true} }
      let(:me) { {inv: [4, 3, 2, 1]} }

      it { is_expected.to be(false) }
    end

    context "when the spell transmutes and would overfill inventory" do
      let(:spell) { {delta0: 2, delta1:2, delta2:-1, delta3:0, :castable=>true} }
      let(:me) { {inv: [1, 1, 1, 5]} }

      it { is_expected.to be(false) }
    end

    context "when the spell requires no ingredients" do
      let(:spell) { {delta0: 2, delta1:0, delta2:0, delta3:0, :castable=>true} }
      let(:me) { {inv: [0, 0, 0, 0]} }

      it { is_expected.to be(true) }
    end

    context "when I have ingredients to cast" do
      let(:me) { {inv: [1, 0, 0, 0]} }

      it { is_expected.to be(true) }
    end

    context "when I have complex ingredients to cast" do
      let(:spell) { {delta0: -1, delta1:-2, delta2:-3, delta3:4, :castable=>true} }
      let(:me) { {inv: [2, 3, 4, 1]} }

      it { is_expected.to be(true) }
    end

    context "when I dont have ingredients to cast" do
      let(:me) { {inv: [0, 1, 1, 1]} }

      it { is_expected.to be(false) }
    end
  end

  describe "#inventory_delta(now, target)" do
    subject(:inventory_delta) { instance.send(:inventory_delta, now, target) }

    let(:now) { [0, 0, 0, 0] }

    context "when im missing everything" do
      let(:target) { [1, 1, 1, 1] }

      it "returns the missing counts" do
        is_expected.to eq([1, 1, 1, 1])
      end
    end

    context "when I have everything" do
      let(:now) { [1, 1, 1, 1] }
      let(:target) { [1, 1, 1, 1] }

      it "returns the missing counts, which are none" do
        is_expected.to eq([0, 0, 0, 0])
      end
    end

    context "when I have something, but missing others" do
      let(:now) { [1, 0, 3, 1] }
      let(:target) { [1, 1, 2, 2] }

      it "returns the missing counts" do
        is_expected.to eq([0, 1, 0, 1])
      end
    end
  end

  describe "#degeneration_spell?(spell)" do
    subject(:degeneration_spell?) { instance.send(:degeneration_spell?, spell) }

    context "when the spell is a definite degenerator" do
      let(:spell) { {delta0: 3, delta1:-1, delta2:0, delta3:0, :castable=>true} }

      it { is_expected.to be(true) }
    end

    context "when the spell is a definite transmuter" do
      let(:spell) { {delta0: 0, delta1:-2, delta2:2, delta3:0, :castable=>true} }

      it { is_expected.to be(false) }
    end

    context "when the spell is a mixture of degen and transmute" do
      let(:spell) { {delta0: 2, delta1:-2, delta2:1, delta3:0, :castable=>true} }

      it { is_expected.to be(false) }
    end

    context "when the spell is a complex transmuter" do
      let(:spell) { {delta0: -1, delta1:-2, delta2:-3, delta3:4, :castable=>true} }

      it { is_expected.to be(false) }
    end
  end

  describe "#pure_giver_spell?(spell)" do
    subject(:pure_giver_spell?) { instance.send(:pure_giver_spell?, spell) }

    context "when the spell is indeed a pure giver" do
      let(:spell) { {delta0: 2, delta1:1, delta2:0, delta3:0, :castable=>true} }

      it { is_expected.to be(true) }
    end

    context "when the spell requires even one ingredient, even if transmuting up" do
      let(:spell) { {delta0: -1, delta1:2, delta2:2, delta3:2, :castable=>true} }

      it { is_expected.to be(false) }
    end
  end
end
