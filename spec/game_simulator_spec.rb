# frozen_string_literal: true

# rspec spec/game_simulator_spec.rb
RSpec.describe GameSimulator do
  let(:instance) { described_class.new }

  describe "#result(start:, move:)" do
    subject(:result) { instance.result(position: position, move: move) }

    context "when simply learning the 1st spell on the 1st move" do
      let(:move) { "LEARN 8" }

      let(:position) do
        {
          actions: {
            8 => {type:"LEARN", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {type:"LEARN", delta0: -1, delta1:-1, delta2:0, delta3:1, price: 0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {type:"LEARN", delta0: -3, delta1:1, delta2:1, delta3:0, price: 0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>true},
            4 => {type:"LEARN", delta0: 3, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>5, :tax_count=>0, :castable=>false, :repeatable=>false},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            82 => {type:"OPPONENT_CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {type:"OPPONENT_CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {type:"OPPONENT_CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [3, 0, 0, 0, 0, 1, ""]
        }
      end

      let(:outcome) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {type:"LEARN", delta0: -1, delta1:-1, delta2:0, delta3:1, price: 0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {type:"LEARN", delta0: -3, delta1:1, delta2:1, delta3:0, price: 0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            4 => {type:"LEARN", delta0: 3, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>false},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            82 => {type:"OPPONENT_CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {type:"OPPONENT_CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {type:"OPPONENT_CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true}
          },
          me: [3, 0, 0, 0, 0, 2, move]
        }
      end

      it "returns the next game state, with spell removed from tome and added to memory" do
        is_expected.to eq(outcome)
      end
    end

    context "when learning a spell that I have to pay tax for" do
      let(:move) { "LEARN 0" }

      let(:position) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {type:"LEARN", delta0: -1, delta1:-1, delta2:0, delta3:1, price: 0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {type:"LEARN", delta0: -3, delta1:1, delta2:1, delta3:0, price: 0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            82 => {type:"OPPONENT_CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {type:"OPPONENT_CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {type:"OPPONENT_CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {type:"OPPONENT_CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 2, ""]
        }
      end

      let(:outcome) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>1, :castable=>false, :repeatable=>true},
            18 => {type:"LEARN", delta0: -1, delta1:-1, delta2:0, delta3:1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {type:"LEARN", delta0: -3, delta1:1, delta2:1, delta3:0, price: 0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            82 => {type:"OPPONENT_CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {type:"OPPONENT_CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {type:"OPPONENT_CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {type:"OPPONENT_CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            88 => described_class::LEARNED_SPELL_DATA[0]
          },
          me: [1, 0, 0, 0, 0, 3, move]
        }
      end

      it "returns a state where I have the spell and paid tax (gone from my inv, and put on next spell, and further spells shifted down" do
        is_expected.to eq(outcome)
      end
    end

    context "when learning a first spell that has tax aquas on it" do
      let(:move) { "LEARN 24" }

      let(:position) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>1, :castable=>false, :repeatable=>true},
            0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {type:"OPPONENT_CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 2, ""]
        }
      end

      let(:outcome) do
        {
          actions: {
            0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {type:"OPPONENT_CAST", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            88 => described_class::LEARNED_SPELL_DATA[24]
          },
          me: [3, 0, 0, 0, 0, 3, move]
        }
      end

      it "returns the next game state, with spell removed from tome and added to memory, and aqua added to my inv" do
        is_expected.to eq(outcome)
      end
    end

    context "when resting" do
      let(:move) { "REST" }

      let(:position) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 3, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            79 => {type:"CAST", delta0: -2, delta1:2, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 2, ""]
        }
      end

      it "returns a state where I have unchanged resources, and all spells refreshed" do
        is_expected.to eq(
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 3, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -2, delta1:2, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 3, "REST"]
        )
      end
    end

    context "when casting a pure giver spell" do
      let(:move) { "CAST 78" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [0, 1, 0, 0, 0, 5, ""]
        }
      end

      it "returns a state where I have more resources and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [2, 1, 0, 0, 0, 6, move],
        )
      end
    end

    context "when casting a vanilla transmute spell" do
      let(:move) { "CAST 79" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [1, 0, 0, 0, 0, 4, ""]
        }
      end

      it "returns a state where I have transmuted resources and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [0, 1, 0, 0, 0, 5, move]
        )
      end
    end

    context "when casting a degen transmute spell" do
      let(:move) { "CAST 10" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {type:"CAST", delta0: 2, delta1:2, delta2:0, delta3:-1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [1, 2, 3, 1, 0, 4, ""]
        }
      end

      it "returns a state where I have transmuted resources and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {type:"CAST", delta0: 2, delta1:2, delta2:0, delta3:-1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [3, 4, 3, 0, 0, 5, move]
        )
      end
    end

    context "when casting a multicast transmute spell" do
      let(:move) { "CAST 10 2" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {type:"CAST", delta0: 2, delta1:2, delta2:0, delta3:-1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [1, 0, 1, 2, 0, 4, ""]
        }
      end

      it "returns a state where I have transmuted resources (x2!) and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {type:"CAST", delta0: 2, delta1:2, delta2:0, delta3:-1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [5, 4, 1, 0, 0, 5, move]
        )
      end
    end

    context "when making an invalid move (two rests in a row)" do
      let(:move) { "REST" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {type:"CAST", delta0: 2, delta1:2, delta2:0, delta3:-1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [1, 0, 1, 2, 0, 4, "REST mehh"]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r'do not rest twice in a row!')
      end
    end

    context "when making an invalid move (learning a spell I can not pay tax for)" do
      let(:move) { "LEARN 4" }

      let(:position) do
        {
          actions: {
            8 => {type:"LEARN", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {type:"LEARN", delta0: -1, delta1:-1, delta2:0, delta3:1, price: 0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {type:"LEARN", delta0: -3, delta1:1, delta2:1, delta3:0, price: 0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>true},
            4 => {type:"LEARN", delta0: 3, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>5, :tax_count=>0, :castable=>false, :repeatable=>false},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [4, 0, 0, 0, 0, 1, ""]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r'insufficient aqua for learning tax!')
      end
    end

    context "when making an invalid move (casting an exhausted spell)" do
      let(:move) { "CAST 79" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [3, 3, 2, 2, 0, 4, ""]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r'spell exhausted!')
      end
    end

    context "when making an invalid move (casting spell that I lack ingredients for)" do
      let(:move) { "CAST 79" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [0, 0, 0, 0, 0, 4, ""]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r'insufficient ingredients for casting!')
      end
    end

    context "when making an invalid move (multicasting spell that I lack ingredients for)" do
      let(:move) { "CAST 86 2" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: -2, delta1:2, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [3, 0, 0, 0, 0, 4, ""]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r'insufficient ingredients for multicasting!')
      end
    end

    context "when making an invalid move (casting a spell that overfills inventory)" do
      let(:move) { "CAST 86" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 2, delta1:2, delta2:0, delta3:-1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [4, 3, 1, 1, 0, 4, ""]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r'casting overfills inventory!')
      end
    end

    context "when making an invalid move (multicasting a spell that does not support it)" do
      let(:move) { "CAST 79 2" }

      let(:position) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [1, 1, 1, 1, 0, 4, ""]
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r"spell can't multicast!")
      end
    end
  end

  describe "#moves_towards(target:, start:)" do
    subject(:moves_towards) { instance.moves_towards(**options) }

    let(:options) { {target: target, start: start, depth: 0} }

    context "when we're already at the target, and should seek to brew or something" do
      let(:target) { [2, 1, 0, 0] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [3, 1, 0, 0, 0, 1, ""]
        }
      end

      it { is_expected.to eq([]) }
    end

    context "when position is very simple, just make Aquas one time" do
      let(:target) { [2, 0, 0, 0] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [0, 0, 0, 0, 0, 1, ""]
        }
      end

      it do
        is_expected.to eq(["CAST 78"])
      end
    end

    context "when position has two competing Aqua producing spells" do
      let(:target) { [2, 0, 0, 0] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 3, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          },
          me: [0, 0, 0, 0, 0, 1, ""],
        }
      end

      it "returns the move that reaches target and produces most bonus" do
        is_expected.to eq(["CAST 86"])
      end
    end

    context "when position is very simple, just make Aquas and rest several times" do
      let(:target) { [6, 0, 0, 0] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: [0, 0, 0, 0, 0, 1, ""]
        }
      end

      it do
        is_expected.to eq(["CAST 78", "REST", "CAST 78", "REST", "CAST 78"])
      end
    end

    context "when position is still simple, just use imba spell and rest combo" do
      let(:target) { [0, 0, 0, 4] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 0, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
          },
          me: [0, 0, 0, 1, 0, 3, "CAST 86"]
        }
      end

      it do
        is_expected.to eq(["REST", "CAST 86", "REST", "CAST 86", "REST", "CAST 86"])
      end
    end

    context "when position is such that saving up and doing a multicast is the best move" do
      let(:target) { [0, 0, 0, 4] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            90 => {type:"CAST", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 3, "REST"]
        }
      end

      it "knows patience and saves Aquas to do a single powerful transmute" do
        is_expected.to eq(["CAST 78", "REST", "CAST 78", "CAST 90 2", "REST", "CAST 78"])
      end
    end

    context "when position is such that saving up for learning is the best move" do
      let(:options) { super().merge(max_depth: 7) }
      let(:target) { [0, 0, 0, 4] }

      let(:start) do
        {
          actions: {
            # 8 => {type:"LEARN", delta0: 3, delta1:-2, delta2:1, delta3:0, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            # 24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            # 0 => {type:"LEARN", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            # 18 => {type:"LEARN", delta0: -1, delta1:-1, delta2:0, delta3:1, price: 0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            # 21 => {type:"LEARN", delta0: -3, delta1:1, delta2:1, delta3:0, price: 0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>true},
            14 => {type:"LEARN", delta0: 0, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>5, :tax_count=>0, :castable=>false, :repeatable=>false},

            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            # 85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          },
          me: [2, 0, 0, 0, 0, 3, "REST"]
        }
      end

      it "knows patience and saves Aquas to learn an imba spell" do
        is_expected.to eq(["CAST 78", "REST", "CAST 78", "LEARN 14", "CAST 82", "REST", "CAST 82"])
      end
    end

    context "when position is such that learning an imba pure giver and a situational degenerator are the best moves" do
      xit "prefers getting the imba spell first, then the degen, and knows to save up" do
        expect(0).to eq(1)
      end
    end

    context "when it's a tricky position where inventory space is limited and a suboptimal transmute needs to be done" do
      # Here we probably want to go for BREW 51, since we have blues, and oranges are easy to make.
      # But perhaps the pro move is to snag the 1st spell with 4  tax points and "LEARN 14"!
      # 68 => {:type=>"BREW", :delta0=>-1, :delta1=>0, :delta2=>-2, :delta3=>-1, :price=>15, :tome_index=>3, :tax_count=>3, :castable=>false, :repeatable=>false},
      # 48 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-2, :delta3=>0, :price=>11, :tome_index=>1, :tax_count=>4, :castable=>false, :repeatable=>false},
      # 56 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-3, :delta3=>0, :price=>13, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
      # 51 => {:type=>"BREW", :delta0=>-2, :delta1=>0, :delta2=>-3, :delta3=>0, :price=>11, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
      # 72 => {:type=>"BREW", :delta0=>0, :delta1=>-2, :delta2=>-2, :delta3=>-2, :price=>19, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>false},
      # 31 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>2, :delta3=>-2, :price=>0, :tome_index=>0, :tax_count=>4, :castable=>false, :repeatable=>true},
      # 1 => {:type=>"LEARN", :delta0=>3, :delta1=>-1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>1, :tax_count=>1, :castable=>false, :repeatable=>true},
      # 32 => {:type=>"LEARN", :delta0=>1, :delta1=>1, :delta2=>3, :delta3=>-2, :price=>0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
      # 18 => {:type=>"LEARN", :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
      # 4 => {:type=>"LEARN", :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>false},
      # 14 => {:type=>"LEARN", :delta0=>0, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>5, :tax_count=>0, :castable=>false, :repeatable=>false},
      # 90 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>2, :delta2=>-2, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
      # 82 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
      # 83 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
      # 84 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
      # 85 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
      # 87 => {:type=>"CAST", :delta0=>1, :delta1=>0, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
      # => me: [5, 0, 0, 0], 0}
      # => meta: {:turn=>12, previous_move: "CAST 87"}
      xit " " do
        expect(0).to eq(1)
      end
    end

    context "when position is such that learning a useless spell just for the tax bonus is the best move" do
      # NB, tax gains will never overflow inventory, so factor that into allowing
      xit " " do
        expect(0).to eq(1)
      end
    end

    context "when an expected error occurs when traversing" do
      let(:target) { [0, 0, 0, 4] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            90 => {type:"CAST", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 3, "REST"]
        }
      end

      before do
        allow(instance).to receive(:result).and_call_original

        allow(instance).to(
          receive(:result).
          with(position: anything, move: "CAST 90 2")
        ).and_raise(SimulatorError.new("mehh"))
      end

      it "ignores the error, merely skips that move branch" do
        is_expected.to include("CAST 79")
      end
    end

    context "when an unexpected error occurs when traversing" do
      let(:target) { [0, 0, 0, 4] }

      let(:start) do
        {
          actions: {
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {type:"CAST", delta0: 0, delta1:-1, delta2:1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {type:"CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            90 => {type:"CAST", delta0: -3, delta1:0, delta2:0, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: [2, 0, 0, 0, 0, 3, "REST"]
        }
      end

      before do
        allow(instance).to receive(:result).and_call_original

        allow(instance).to(
          receive(:result).
          with(position: anything, move: "CAST 90 2")
        ).and_raise("whoa there")
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(
          RuntimeError,
          %r'Path \["CAST 78", "REST", "CAST 78", "CAST 90 2"\] leads to err: \'whoa there\' in'
        )
      end
    end
  end

  describe "#distance_from_target(target:, inv:)" do
    subject(:distance_from_target) { instance.distance_from_target(**options) }

    let(:options) { {target: target, inv: inv} }

    context "when precisely at target" do
      let(:target) { [1, 0, 0, 0] }
      let(:inv) { target }

      it { is_expected.to eq(distance: 0, bonus: 0) }
    end

    context "when slightly over target" do
      let(:target) { [1, 0, 0, 0] }
      let(:inv) { [2, 1, 0, 0] }

      it { is_expected.to eq(distance: 0, bonus: 3) }
    end

    context "when under target" do
      let(:target) { [1, 0, 1, 0] }
      let(:inv) { [0, 1, 0, 0] }

      it { is_expected.to eq(distance: 4, bonus: 2) }
    end
  end

  describe "#moves_from(position:)" do
    subject(:moves_from) { instance.moves_from(position: position) }

    context "when all categories of actions are possible" do
      # - learning
      # - casting
      # - multicasting
      # - rest
      let(:position) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {type:"OPPONENT_CAST", delta0: 0, delta1:0, delta2:-1, delta3:1, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {type:"CAST", delta0: 0, delta1:-2, delta2:2, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            87 => {type:"CAST", delta0: 0, delta1:2, delta2:-1, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true}
          },
          me: [0, 4, 0, 0, 0, 1, ""]
        }
      end

      it "returns an array of moves to try" do
        is_expected.to contain_exactly(
          "REST", "LEARN 24", "CAST 78", "CAST 86", "CAST 86 2"
        )
      end
    end

    context "when just rested" do
      let(:position) do
        {
          actions: {
            24 => {type:"LEARN", delta0: 0, delta1:3, delta2:0, delta3:-1, price: 0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {type:"CAST", delta0: 2, delta1:0, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
          },
          me: [0, 4, 0, 0, 0, 1, "REST"]
        }
      end

      it "does not include resting among moves to try" do
        is_expected.to contain_exactly("LEARN 24", "CAST 78")
      end
    end
  end

  describe "#possible_cast_times(spell:, inv:)" do
    subject(:possible_cast_times) do
      instance.possible_cast_times(spell: spell, inv: inv)
    end

    context "when spell is exhausted" do
      let(:spell) do
        {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false}
      end

      let(:inv) { [2,0,0,0] }

      it { is_expected.to eq(0) }
    end

    context "when spell is castable, but lacking inv" do
      let(:spell) do
        {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
      end

      let(:inv) { [0,0,0,0] }

      it { is_expected.to eq(0) }
    end

    context "when a non-repeatable spell can be cast once" do
      let(:spell) do
        {type:"CAST", delta0: -1, delta1:1, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
      end

      let(:inv) { [1,0,0,0] }

      it { is_expected.to eq(1) }
    end

    context "when a repeatable spell can be cast once" do
      let(:spell) do
        {type:"CAST", delta0: -2, delta1:2, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true}
      end

      let(:inv) { [3,0,0,0] }

      it { is_expected.to eq(1) }
    end

    context "when a repeatable spell can be cast twice" do
      let(:spell) do
        {type:"CAST", delta0: -2, delta1:2, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true}
      end

      let(:inv) { [5,0,0,0] }

      it { is_expected.to eq(2) }
    end

    context "when a repeatable spell can be cast five times, the max" do
      let(:spell) do
        {type:"CAST", delta0: -2, delta1:2, delta2:0, delta3:0, price: 0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true}
      end

      let(:inv) { [10,0,0,0] }
      it { is_expected.to eq(5) }
    end
  end

  describe "#can_cast?(operation:, from:)" do
    subject(:can_cast?) { instance.can_cast?(operation: operation, from: from) }

    context "when ingredients suffice for casting" do
      let(:operation) { [-2, 1, 1, 1] }
      let(:from) { [3, 0, 1, 2] }

      it "returns true, and memoizes" do
        is_expected.to eq(can: true)

        # # now setting the cache ivar by force to see it's preferred
        # key = [operation, from]
        # instance.instance_variable_set("@cast_cache", {key => false})

        # expect(
        #   instance.can_cast?(operation: operation, from: from)
        # ).to be(false)

        # # forcing some random value
        # key = [operation, from]
        # instance.instance_variable_set("@cast_cache", {key => :mehh})

        # expect(
        #   instance.can_cast?(operation: operation, from: from)
        # ).to eq(:mehh)

        # # and back to true
        # key = [operation, from]
        # instance.instance_variable_set("@cast_cache", {})

        expect(
          instance.can_cast?(operation: operation, from: from)
        ).to eq(can: true)
      end
    end

    context "when ingredients suffice for casting, but overflow inventory" do
      let(:operation) { [-2, 1, 1, 1] }
      let(:from) { [2, 2, 4, 2] }

      it "returns false, and memoizes" do
        is_expected.to eq(can: false, detail: :overflow)
      end
    end

    context "when ingredients not sufficient for casting" do
      let(:operation) { [-2, 1, 1, 1] }
      let(:from) { [1, 2, 4, 2] }

      it "returns false, and memoizes" do
        is_expected.to eq(can: false, detail: :insufficient_ingredients)
      end
    end
  end
end
