# frozen_string_literal: true

# rspec spec/game_turn_spec.rb
RSpec.describe GameTurn do
  let(:instance) { described_class.new(**options) }
  let(:options) { {actions: actions, me: me, opp: opp} }
  let(:actions) { {} }
  let(:me) { [] }
  let(:opp) { [] }

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
        let(:me) { [2, 2, 3, 3] }

        it "moves to brew the best potion" do
          is_expected.to include("BREW 61")
        end
      end

      context "when I dont have enough resources for the most lucrative potion, but do for the second" do
        let(:me) { [2, 2, 3, 1] }

        it "moves to brew the second best" do
          is_expected.to include("BREW 54")
        end
      end
    end

    context "when there's spells to learn, but they're all degenerators" do
      let(:me) { [3, 2, 0, 0, 3] }

      let(:actions) do
        {
          11 => ["LEARN", 2, 2, -1, 0, 0, 0],
          10 => ["LEARN", 4, -1, 0, 0, 1, 0],
          44 => {type: "BREW", delta0: 0, delta1:-2, delta2:0, delta3:0, :price=>8},
        }
      end

      before { allow(instance).to receive(:simplest_potion_id).and_return(44) }

      it "skips learning, opting to get to brewing instead" do
        is_expected.to include("BREW 44")
      end
    end

    context "when there's pure giver spell to learn and it's early in the game" do
      let(:me) { [3, 2, 0, 0, 3] }

      let(:actions) do
        {
          11 => ["LEARN", 0, -2, 2, 0, 0, 0],
          10 => ["LEARN", 2, 1, 0, 0, 1, 0]
        }
      end

      it "returns the move to learn the pure giver spell" do
        is_expected.to include("LEARN 10")
      end
    end

    context "when there's a regular transmuter to learn and it's early in the game" do
      let(:me) { [3, 2, 0, 0, 3] }

      let(:actions) do
        {
          11 => ["LEARN", 0, -2, 2, 0, 0, 0],
          10 => ["LEARN", 3, -2, 0, 0, 1, 0]
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
          1 => ["CAST", 2, 0, 0, 0, true, false],
          2 => ["CAST", -1, 1, 0, 0, true, false],
          3 => ["CAST", 0, -1, 1, 0, true, false],
          4 => ["CAST", 0, 0, -1, 1, true, false]
        }
      end

      let(:me) { [3, 0, 0, 0, 51] }

      it "returns the move to transmute to green" do
        is_expected.to include("CAST 2")
      end
    end

    context "when I've just made a green one and should just rest to get another" do
      let(:me) { [2, 1, 1, 1, 51] }

      let(:actions) do
        {
          53 => {type:"BREW", delta0: 0, delta1:0, delta2:-4, delta3:0, :price=>15, :tome_index=>3, :tax_count=>3, :castable=>false, :repeatable=>false},
          58 => {type:"BREW", delta0: 0, delta1:-3, delta2:0, delta3:-2, :price=>15, :tome_index=>1, :tax_count=>3, :castable=>false, :repeatable=>false},
          70 => {type:"BREW", delta0: -2, delta1:-2, delta2:0, delta3:-2, :price=>15, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          67 => {type:"BREW", delta0: 0, delta1:-2, delta2:-1, delta3:-1, :price=>12, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          77 => {type:"BREW", delta0: -1, delta1:-1, delta2:-1, delta3:-3, :price=>20, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, false, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false]
        }
      end

      it "returns a move to just rest to make another green" do
        is_expected.to include("REST")
      end
    end

    context "when we've a bunch of spells" do
      let(:me) { [6, 2, 1, 0, 51] } # total of 9

      let(:actions) do
        {
          79 => ["CAST", 4, 1, -1, 0, -1, true, false],
          2 => ["CAST", -1, 1, 0, 0, -1, true, false],
          3 => ["CAST", 0, 2, -1, 0, -1, true, false],
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

          # [type, (1..4)inv, 5=tome_index, 6=tax_bonus]
          36 => ["LEARN", 0, -3, 3, 0, 0, 0],
          31 => ["LEARN", 0, 3, 2, -2, 1, 0],
          34 => ["LEARN", -2, 0, -1, 2, 2, 0],
          16 => ["LEARN", 1, 0, 1, 0, 3, 0],
          1 => ["LEARN", 3, -1, 0, 0, 4, 0],
          22 => ["LEARN", 0, 2, -2, 1, 5, 0],

          # [type, (1..4)inv, 5=castable, 6=repeatable]
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false]
        }
      end

      let(:me) { [3, 0, 0, 0, 0, 1, ""] }

      it "returns the first step towards easy brewin of leftmost potion" do
        is_expected.to start_with("LEARN 16")
      end
    end

    context "when going for that leftmost potion, but an excellent (+4) giver spell is in the 6th position" do
      let(:actions) do
        {
          0 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-3, :delta3=>-1, :price=>21, :tome_index=>3, :tax_count=>4, :castable=>false, :repeatable=>false},
          1 => ["LEARN", 3, -1, 0, 0, 0, 1],
          18 => ["LEARN", -1, -1, 0, 1, 1, 0],
          9 => ["LEARN", 2, -3, 2, 0, 2, 0],
          24 => ["LEARN", 0, 3, 0, -1, 3, 0],
          23 => ["LEARN", 1, -3, 1, 1, 4, 0],
          15 => ["LEARN", 0, 2, 0, 0, 5, 0], # our baby
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false],
          87 => ["CAST", 0, 0, 0, 1, true, false],
          90 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>2, :delta2=>-1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
        }
      end

      let(:me) { [2, 0, 0, 1, 0, 5, "REST let's brew 52 via [REST, CAST 87, CAST 78]"] }
      let(:opp) { [2, 1, 0, 0, 0, 5, "REST"] }

      it "tentatively accumulates aquas to be in a position to learn later" do
        is_expected.to start_with("CAST 78") # eq("LEARN 15")
      end
    end

    context "when rushing [0, 0, 0, 1] is the best move" do
      let(:actions) do
        {
          6 => ["LEARN", 2, 1, -2, 1, 0, 0],
          36 => ["LEARN", 0, -3, 3, 0, 1, 0],
          35 => ["LEARN", 0, 0, -3, 3, 2, 0],
          19 => ["LEARN", 0, 2, -1, 0, 3, 0],
          14 => ["LEARN", 0, 0, 0, 1, 4, 0], # our baby
          1 => ["LEARN", 3, -1, 0, 0, 5, 0],
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false],
          85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
        }
      end

      let(:me) { [3, 0, 0, 0, 0, 1, ""] }

      it "returns the first step in the road to snagging spell 14" do
        is_expected.to start_with("CAST 78") # followed by rest and another "CAST 78"
      end
    end

    context "when first spells have a lot of tax on them and opponent is not on the offensive (worth below 5)" do
      let(:actions) do
        {
          76 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-3, :delta3=>-1, :price=>21, :tome_index=>3, :tax_count=>4, :castable=>false, :repeatable=>false},
          50 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>0, :delta3=>-2, :price=>11, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
          62 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>0, :delta3=>-3, :price=>16, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          56 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-3, :delta3=>0, :price=>13, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          43 => {:type=>"BREW", :delta0=>-3, :delta1=>-2, :delta2=>0, :delta3=>0, :price=>7, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          39 => ["LEARN", 0, 0, -2, 2, 0, 4],
          8 => ["LEARN", 3, -2, 1, 0, 1, 4],
          28 => ["LEARN", 4, 1, -1, 0, 2, 0],
          10 => ["LEARN", 2, 2, 0, -1, 3, 0],
          11 => ["LEARN", -4, 0, 2, 0, 4, 0],
          19 => ["LEARN", 0, 2, -1, 0, 5, 0],
          82 => ["CAST", 2, 0, 0, 0, true, false],
          83 => ["CAST", -1, 1, 0, 0, true, false],
          84 => ["CAST", 0, -1, 1, 0, true, false],
          85 => ["CAST", 0, 0, -1, 1, true, false],
          89 => ["CAST", 0, -3, 0, 2, true, true],
          91 => ["CAST", 0, 2, 0, 0, true, false],
          93 => ["CAST", 0, -2, 2, 0, true, true],
          95 => ["CAST", 1, 1, 0, 0, true, false],
          94 => {:type=>"OPPONENT_CAST", :delta0=>1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
        }
      end

      let(:me) { [3, 0, 1, 0, 0, 8, "LEARN 2"] }
      let(:opp) { [0, 0, 0, 0, 0, 8, "LEARN 2"] } # yup, we both learned spell 2

      it "prefers learning" do
        is_expected.to start_with("LEARN 39")
      end
    end

    context "when it's a real situation where learning a strategic degenerator is the way to go" do
      let(:actions) do
        {
          57 => {:type=>"BREW", :delta0=>0, :delta1=>0, :delta2=>-2, :delta3=>-2, :price=>17, :tome_index=>3, :tax_count=>4, :castable=>false, :repeatable=>false},
          50 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>0, :delta3=>-2, :price=>11, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
          44 => {:type=>"BREW", :delta0=>0, :delta1=>-4, :delta2=>0, :delta3=>0, :price=>8, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          77 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-1, :delta3=>-3, :price=>20, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          66 => {:type=>"BREW", :delta0=>-2, :delta1=>-1, :delta2=>0, :delta3=>-1, :price=>9, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          1 => ["LEARN", 3, -1, 0, 0, 0, 2],
          35 => ["LEARN", 0, 0, -3, 3, 1, 2],
          31 => ["LEARN", 0, 3, 2, -2, 2, 2], # ultimate goal
          5 => ["LEARN", 2, 3, -2, 0, 3, 0],
          30 => ["LEARN", -4, 0, 1, 1, 4, 0],
          17 => ["LEARN", -2, 0, 1, 0, 5, 0],
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false],
          86 => ["CAST", 0, 0, 0, 1, true, false],
          87 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
        }
      end

      let(:me) { [0, 0, 0, 0, 0, 2, "LEARN 14"] }

      it "returns a move to learn the first spell, which will give tax rebate and allow learning the very situationally awesome 31" do
        is_expected.to start_with("LEARN 1")
      end
    end

    context "when it's a no-brainer transmuter learning time" do
      let(:actions) do
        {
          56 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-3, :delta3=>0, :price=>16, :tome_index=>3, :tax_count=>4, :castable=>false, :repeatable=>false},
          51 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>-3, :delta3=>0, :price=>12, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
          77 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-1, :delta3=>-3, :price=>20, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          71 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>-2, :delta3=>-2, :price=>17, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          60 => {:type=>"BREW", :delta0=>0, :delta1=>0, :delta2=>-5, :delta3=>0, :price=>15, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          20 => ["LEARN", 2, -2, 0, 1, 0, 0], # This is it right here, we have green givers, and this is green taker
          34 => ["LEARN", -2, 0, -1, 2, 1, 0],
          33 => ["LEARN", -5, 0, 3, 0, 2, 0],
          29 => ["LEARN", -5, 0, 0, 2, 3, 0],
          21 => ["LEARN", -3, 1, 1, 0, 4, 0],
          9 => ["LEARN", 2, -3, 2, 0, 5, 0],
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false],
          86 => ["CAST", 0, 2, 0, 0, false, false], # pure green giver
          88 => ["CAST", 1, 1, 0, 0, true, false], # 1, 1 pure giver
          90 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-2, :delta3=>2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
        }
      end

      let(:me) { [2, 2, 0, 0, 0, 4, "CAST 86"] }

      # suffers the problem of becoming too eager on learning transmuters.
      # Need to check existing transmuter count not to create a bottleneck
      xit "returns the move to learn a transmuter from green, will definitely come in handly" do
        is_expected.to start_with("LEARN 20")
      end
    end

    context "when a real good spell is available, a real example" do
      let(:actions) do
        {
          57 => {:type=>"BREW", :delta0=>0, :delta1=>0, :delta2=>-2, :delta3=>-2, :price=>17, :tome_index=>3, :tax_count=>4, :castable=>false, :repeatable=>false},
          64 => {:type=>"BREW", :delta0=>0, :delta1=>0, :delta2=>-2, :delta3=>-3, :price=>19, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
          49 => {:type=>"BREW", :delta0=>0, :delta1=>-5, :delta2=>0, :delta3=>0, :price=>10, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          73 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-1, :delta3=>-1, :price=>12, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          59 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>0, :delta3=>-3, :price=>14, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          33 => ["LEARN", -5, 0, 3, 0, 0, 0], # the very rare net +4 spell
          0 => ["LEARN", -3, 0, 0, 1, 1, 0],
          38 => ["LEARN", -2, 2, 0, 0, 2, 0],
          25 => ["LEARN", 0, -3, 0, 2, 3, 0],
          27 => ["LEARN", 1, 2, -1, 0, 4, 0],
          35 => ["LEARN", 0, 0, -3, 3, 5, 0],
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false],
          85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
        }
      end

      let(:me) { [3, 0, 0, 0, 0, 1, ""] }
      let(:opp) { [3, 0, 0, 0, 0, 1, ""] }

      it "goes for learning the transmuter with huge net advantage" do
        is_expected.to start_with("LEARN 33")
      end
    end

    context "when I already have all the ingredients for a good potion" do
      let(:actions) do
        {
          76 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-3, :delta3=>-1, :price=>19, :tome_index=>1, :tax_count=>3, :castable=>false, :repeatable=>false},
          # this is the one we can brew
          58 => {:type=>"BREW", :delta0=>0, :delta1=>-3, :delta2=>0, :delta3=>-2, :price=>14, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          72 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-2, :delta3=>-2, :price=>19, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          56 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-3, :delta3=>0, :price=>13, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          46 => {:type=>"BREW", :delta0=>-2, :delta1=>-3, :delta2=>0, :delta3=>0, :price=>8, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          6 => ["LEARN", 2, 1, -2, 1, 0, 0],
          26 => ["LEARN", 1, 1, 1, -1, 1, 0],
          20 => ["LEARN", 2, -2, 0, 1, 2, 0],
          21 => ["LEARN", -3, 1, 1, 0, 3, 0],
          25 => ["LEARN", 0, -3, 0, 2, 4, 0],
          1 => ["LEARN", 3, -1, 0, 0, 5, 0],
          82 => ["CAST", 2, 0, 0, 0, true, false],
          83 => ["CAST", -1, 1, 0, 0, false, false],
          84 => ["CAST", 0, -1, 1, 0, true, false],
          85 => ["CAST", 0, 0, -1, 1, true, false],
          81 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
        }
      end

      let(:me) { [1, 3, 0, 2, 56, 67, "CAST 83 let's brew 46 via [CAST 83, CAST 82]"] }

      it "returns a move to brew it, not got for the cheapest potion" do
        is_expected.to start_with("BREW 58")
      end
    end

    context "when it's a real situation that times out" do
      let(:actions) do
        {
          77 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-1, :delta3=>-3, :price=>21, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
          74 => {:type=>"BREW", :delta0=>-3, :delta1=>-1, :delta2=>-1, :delta3=>-1, :price=>14, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          68 => {:type=>"BREW", :delta0=>-1, :delta1=>0, :delta2=>-2, :delta3=>-1, :price=>12, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          76 => {:type=>"BREW", :delta0=>-1, :delta1=>-1, :delta2=>-3, :delta3=>-1, :price=>18, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          65 => {:type=>"BREW", :delta0=>0, :delta1=>0, :delta2=>0, :delta3=>-5, :price=>20, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
          20 => ["LEARN", 2, -2, 0, 1, 0, 0],
          34 => ["LEARN", -2, 0, -1, 2, 1, 0],
          33 => ["LEARN", -5, 0, 3, 0, 2, 0],
          26 => ["LEARN", 1, 1, 1, -1, 3, 0],
          7 => ["LEARN", 3, 0, 1, -1, 4, 0],
          37 => ["LEARN", -3, 3, 0, 0, 5, 0],
          78 => ["CAST", 2, 0, 0, 0, true, false],
          79 => ["CAST", -1, 1, 0, 0, true, false],
          80 => ["CAST", 0, -1, 1, 0, true, false],
          81 => ["CAST", 0, 0, -1, 1, true, false],
          87 => ["CAST", 0, 0, 0, 1, false, false],
          92 => ["CAST", 0, 2, 0, 0, false, false],
          95 => ["CAST", 0, 3, 0, -1, false, true],
          97 => ["CAST", 1, -3, 1, 1, false, true],
          98 => ["CAST", -5, 0, 0, 2, true, true],
          99 => {:type=>"OPPONENT_CAST", :delta0=>-5, :delta1=>0, :delta2=>0, :delta3=>2, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
        }
      end

      let(:me) { [0, 0, 0, 0, 44, 23, "BREW 75"] }
      let(:opp) { [0, 0, 0, 0, 44, 23, "BREW 75"] }

      it "runs in under 50ms" do
        runtime = Benchmark.realtime do
          is_expected.to match(%r'\A((REST)|(CAST 78))')
        end * 1000

        expect(runtime).to be < 50 # as below 50ms

        # "let's brew 74 via [REST, CAST 87, CAST 95, CAST 78, CAST 97, CAST 92]"
        #                 or [REST, CAST 87, CAST 78, CAST 95, CAST 97, CAST 92]"
      end
    end
  end

  describe "array vs hash dup" do
    before(:all) do
      TestProf::StackProf.run
    end

    it "compares time it takes to dup array vs a hash 40k times" do
      hash = {type:"MEHH", delta0: 4, delta1:1, delta2:-1, delta3:0, price: 0, :tt=>-1, :tx=>-1, :cc=>true, :repeatable=>false}
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
        1 => ["CAST",  2, 0, 0, 0, true, false],
        2 => ["CAST",  -1, 1, 0, 0, true, false],
        3 => ["CAST",  0, -1, 1, 0, true, false],
        4 => ["CAST",  0, 0, -1, 1, true, false]
      }
    end

    let(:me) { [] }

    context "when lacking a yellow" do
      let(:target_inventory) { [0, 0, 0, 1] }

      context "when spell is available and orange is available" do
        let(:me) { [0, 0, 1, 0] }

        it "returns the move to cast orange->yellow spell" do
          is_expected.to include("CAST 4")
        end
      end

      context "when I know several spells to transmute to yellow" do
        let(:actions) do
          s = super()
          s[4][5] = false
          s[5] = ["CAST", 0, -1, 0, 1, true, false]
          s
        end

        let(:me) { [0, 1, 0, 0] }

        it "returns the move to cast the available spell" do
          is_expected.to include("CAST 5")
        end
      end

      context "when yellow can not be created due to orange missing but orange can be created" do
        let(:me) { [0, 1, 0, 0] }

        let(:actions) { super().tap{ |a| a[4][5] = false } }

        it "returns the move to cast green->orange spell" do
          is_expected.to include("CAST 3")
        end
      end

      context "when yellow can not be created due to orange missing and green missing, but green can be made" do
        let(:me) { [1, 0, 0, 0] }

        it "returns the move to cast blue->green spell" do
          is_expected.to include("CAST 2")
        end
      end

      context "when yellow can not be created due to everything missing" do
        let(:me) { [0, 0, 0, 0] }

        it "returns the move to cast blue++" do
          is_expected.to include("CAST 1")
        end
      end

      context "when nothing can be cast" do
        let(:actions) { super().tap{ |s| s[1][5] = false } }
        let(:me) { [0, 0, 0, 0] }

        it "returns the move to REST" do
          is_expected.to include("REST")
        end
      end
    end
  end

  describe "#i_can_cast?(spell)" do
    subject(:i_can_cast?) { instance.send(:i_can_cast?, spell) }

    let(:spell) { ["CAST", -1, 1, 0, 0, true] }

    context "when the spell would overfill inventory" do
      let(:spell) { ["CAST", 1, 0, 0, 0, true] }
      let(:me) { [4, 3, 2, 1] }

      it { is_expected.to be(false) }
    end

    context "when the spell transmutes and would overfill inventory" do
      let(:spell) { ["CAST", 2, 2, -1, 0, true] }
      let(:me) { [1, 1, 1, 5] }

      it { is_expected.to be(false) }
    end

    context "when the spell requires no ingredients" do
      let(:spell) { ["CAST", 2, 0, 0, 0, true] }
      let(:me) { [0, 0, 0, 0] }

      it { is_expected.to be(true) }
    end

    context "when I have ingredients to cast" do
      let(:me) { [1, 0, 0, 0] }

      it { is_expected.to be(true) }
    end

    context "when I have complex ingredients to cast" do
      let(:spell) { ["CAST", -1, -2, -3, 4, true, true] }
      let(:me) { [2, 3, 4, 1] }

      it { is_expected.to be(true) }
    end

    context "when I don't have ingredients to cast" do
      let(:me) { [0, 1, 1, 1] }

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
