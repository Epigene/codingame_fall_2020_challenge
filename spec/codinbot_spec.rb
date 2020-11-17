RSpec.describe Codinbot do
  it "has a version number" do
    expect(Codinbot::VERSION).not_to be nil
  end

  it "does something useful" do
  end

  describe "Array#add(other)" do
    subject(:add) { array.add(other) }

    context "when adding positive values" do
      let(:array) { [1,2,3,4] }
      let(:other) { [2,1,3,1] }

      it "returns simple sums of inventory positions" do
        is_expected.to eq([3, 3, 6, 5])
      end
    end

    context "when adding negative values" do
      let(:array) { [2,4,6,8] }
      let(:other) { [-1,-2,-3,-4] }

      it "returns an array of values subtracted" do
        is_expected.to eq([1,2,3,4])
      end
    end
  end
end
