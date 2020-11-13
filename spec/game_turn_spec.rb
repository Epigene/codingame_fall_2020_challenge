# frozen_string_literal: true

# rspec spec/game_turn_spec.rb
RSpec.describe GameTurn do
  let(:instance) { described_class.new(**options) }
  let(:options) { {actions: actions, me: me, opp: opp} }
  let(:opp) { {} }

  describe "#move" do
    subject(:move) { instance.move }

    context "when initialized with reference state 1" do
      let(:actions) do
        {
          44 => {:delta_0=>0, :delta_1=>-2, :delta_2=>0, :delta_3=>0, :price=>8},
          42 => {:delta_0=>-1, :delta_1=>-1, :delta_2=>0, :delta_3=>0, :price=>6},
          61 => {:delta_0=>0, :delta_1=>0, :delta_2=>0, :delta_3=>-2, :price=>16},
          50 => {:delta_0=>-1, :delta_1=>0, :delta_2=>0, :delta_3=>-1, :price=>10},
          54 => {:delta_0=>0, :delta_1=>-1, :delta_2=>0, :delta_3=>-1, :price=>12}
        }
      end

      context "when I have enough ingredients for the most lucrative potion" do
        let(:me) { {:inv_0=>2, :inv_1=>2, :inv_2=>3, :inv_3=>3} }

        it "moves to brew the best potion" do
          is_expected.to eq("BREW 61")
        end
      end

      context "when I dont have enough resources for the most lucrative potion, but do for the second" do
        let(:me) { {:inv_0=>2, :inv_1=>2, :inv_2=>3, :inv_3=>1} }

        it "moves to brew the second best" do
          is_expected.to eq("BREW 54")
        end
      end
    end
  end
end
