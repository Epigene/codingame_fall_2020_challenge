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
            8 => {:type=>"LEARN", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {:type=>"LEARN", :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {:type=>"LEARN", :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {:type=>"LEARN", :delta0=>-3, :delta1=>1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>true},
            4 => {:type=>"LEARN", :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>5, :tax_count=>0, :castable=>false, :repeatable=>false},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            82 => {:type=>"OPPONENT_CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {:type=>"OPPONENT_CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[3, 0, 0, 0], :score=>0},
          meta: {turn: 1}
        }
      end

      let(:outcome) do
        position.dup.tap do |p|
          p[:actions] = {
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {:type=>"LEARN", :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {:type=>"LEARN", :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {:type=>"LEARN", :delta0=>-3, :delta1=>1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            4 => {:type=>"LEARN", :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>false},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            82 => {:type=>"OPPONENT_CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {:type=>"OPPONENT_CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {:type=>"CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true}
          }

          p[:meta][:turn] = 2
        end
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
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {:type=>"LEARN", :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {:type=>"LEARN", :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {:type=>"LEARN", :delta0=>-3, :delta1=>1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {:type=>"CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            82 => {:type=>"OPPONENT_CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {:type=>"OPPONENT_CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {:type=>"OPPONENT_CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: {:inv=>[2, 0, 0, 0], :score=>0},
          meta: {turn: 2}
        }
      end

      let(:outcome) do
        position.dup.tap do |p|
          p[:actions] = {
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>0, :tax_count=>1, :castable=>false, :repeatable=>true},
            18 => {:type=>"LEARN", :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {:type=>"LEARN", :delta0=>-3, :delta1=>1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {:type=>"CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            82 => {:type=>"OPPONENT_CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            83 => {:type=>"OPPONENT_CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            84 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {:type=>"OPPONENT_CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            88 => described_class::LEARNED_SPELL_DATA[0]
          }

          p[:meta][:turn] = 3
          p[:me] = {:inv=>[1, 0, 0, 0], :score=>0}
        end
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
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>0, :tax_count=>1, :castable=>false, :repeatable=>true},
            0 => {:type=>"LEARN", :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {:type=>"OPPONENT_CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: {:inv=>[2, 0, 0, 0], :score=>0},
          meta: {turn: 2}
        }
      end

      let(:outcome) do
        position.dup.tap do |p|
          p[:actions] = {
            0 => {:type=>"LEARN", :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            80 => {:type=>"CAST", :delta0=>0, :delta1=>-1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            81 => {:type=>"CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            87 => {:type=>"OPPONENT_CAST", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            88 => described_class::LEARNED_SPELL_DATA[24]
          }

          p[:meta][:turn] = 3
          p[:me] = {:inv=>[3, 0, 0, 0], :score=>0}
        end
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
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {:type=>"CAST", :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-2, :delta1=>2, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
          },
          me: {:inv=>[2, 0, 0, 0], :score=>0},
          meta: {turn: 2}
        }
      end

      it "returns a state where I have unchanged resources, and all spells refreshed" do
        is_expected.to eq(
          actions: {
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            78 => {:type=>"CAST", :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-2, :delta1=>2, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
          },
          me: {:inv=>[2, 0, 0, 0], :score=>0},
          meta: {turn: 3}
        )
      end
    end

    context "when casting a pure giver spell" do
      let(:move) { "CAST 78" }

      let(:position) do
        {
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[0, 1, 0, 0], :score=>0},
          meta: {:turn=>5}
        }
      end

      it "returns a state where I have more resources and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[2, 1, 0, 0], :score=>0},
          meta: {:turn=>6}
        )
      end
    end

    context "when casting a vanilla transmute spell" do
      let(:move) { "CAST 79" }

      let(:position) do
        {
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[1, 0, 0, 0], :score=>0},
          meta: {:turn=>4}
        }
      end

      it "returns a state where I have transmuted resources and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[0, 1, 0, 0], :score=>0},
          meta: {:turn=>5}

        )
      end
    end

    context "when casting a degen transmute spell" do
      let(:move) { "CAST 10" }

      let(:position) do
        {
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {:type=>"CAST", :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[1, 2, 3, 1], :score=>0},
          meta: {:turn=>4}
        }
      end

      it "returns a state where I have transmuted resources and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {:type=>"CAST", :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[3, 4, 3, 0], :score=>0},
          meta: {:turn=>5}
        )
      end
    end

    context "when casting a multicast transmute spell" do
      let(:move) { "CAST 10 2" }

      let(:position) do
        {
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {:type=>"CAST", :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[1, 0, 1, 2], :score=>0},
          meta: {:turn=>4}
        }
      end

      it "returns a state where I have transmuted resources (x2!) and spell is exhausted" do
        is_expected.to eq(
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {:type=>"CAST", :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[5, 4, 1, 0], :score=>0},
          meta: {:turn=>5}
        )
      end
    end

    context "when making an invalid move (two rests in a row)" do
      let(:move) { "REST" }

      let(:position) do
        {
          actions: {
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            10 => {:type=>"CAST", :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[1, 0, 1, 2], :score=>0},
          meta: {:turn=>4, previous_move: "REST mehh"}
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
            8 => {:type=>"LEARN", :delta0=>3, :delta1=>-2, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>0, :tax_count=>0, :castable=>false, :repeatable=>true},
            24 => {:type=>"LEARN", :delta0=>0, :delta1=>3, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>1, :tax_count=>0, :castable=>false, :repeatable=>true},
            0 => {:type=>"LEARN", :delta0=>-3, :delta1=>0, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>2, :tax_count=>0, :castable=>false, :repeatable=>true},
            18 => {:type=>"LEARN", :delta0=>-1, :delta1=>-1, :delta2=>0, :delta3=>1, :price=>0, :tome_index=>3, :tax_count=>0, :castable=>false, :repeatable=>true},
            21 => {:type=>"LEARN", :delta0=>-3, :delta1=>1, :delta2=>1, :delta3=>0, :price=>0, :tome_index=>4, :tax_count=>0, :castable=>false, :repeatable=>true},
            4 => {:type=>"LEARN", :delta0=>3, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>5, :tax_count=>0, :castable=>false, :repeatable=>false},
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[4, 0, 0, 0], :score=>0},
          meta: {turn: 1}
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
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>false, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[3, 3, 2, 2], :score=>0},
          meta: {:turn=>4}
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
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[0, 0, 0, 0], :score=>0},
          meta: {:turn=>4}
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
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {:type=>"CAST", :delta0=>-2, :delta1=>2, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[3, 0, 0, 0], :score=>0},
          meta: {:turn=>4}
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
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            86 => {:type=>"CAST", :delta0=>2, :delta1=>2, :delta2=>0, :delta3=>-1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>true},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[4, 3, 1, 1], :score=>0},
          meta: {:turn=>4}
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
            78 => {:type=>"CAST", :delta0=>2, :delta1=>0, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            79 => {:type=>"CAST", :delta0=>-1, :delta1=>1, :delta2=>0, :delta3=>0, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false},
            85 => {:type=>"OPPONENT_CAST", :delta0=>0, :delta1=>0, :delta2=>-1, :delta3=>1, :price=>0, :tome_index=>-1, :tax_count=>-1, :castable=>true, :repeatable=>false}
          },
          me: {:inv=>[1, 1, 1, 1], :score=>0},
          meta: {:turn=>4}
        }
      end

      it "raises a descriptive error" do
        expect{ subject }.to raise_error(RuntimeError, %r"spell can't multicast!")
      end
    end
  end

  describe "#moves_towards(inv:, start:, just_rested: false)" do
    subject(:moves_towards) { instance.moves_towards(**options) }

    context "when an error occurs when traversing" do
      it "immediately returns the moves that lead to error" do
        is_expected.to eq(1)
      end
    end

    context "when " do
      it "knows patience and saves Aquas to do a single powerful transmute" do
        is_expected.to eq(1)
      end
    end
  end

  describe "#can_cast?(operation:, from:)" do
    subject(:can_cast?) { instance.can_cast?(operation: operation, from: from) }

    context "when ingredients suffice for casting" do
      let(:operation) { [-2, 1, 1, 1] }
      let(:from) { [3, 0, 1, 2] }

      it "returns true, and memoizes" do
        is_expected.to eq(can: true)

        # now setting the cache ivar by force to see it's preferred
        key = [operation, from]
        instance.instance_variable_set("@cast_cache", {key => false})

        expect(
          instance.can_cast?(operation: operation, from: from)
        ).to be(false)

        # forcing some random value
        key = [operation, from]
        instance.instance_variable_set("@cast_cache", {key => :mehh})

        expect(
          instance.can_cast?(operation: operation, from: from)
        ).to eq(:mehh)

        # and back to true
        key = [operation, from]
        instance.instance_variable_set("@cast_cache", {})

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
