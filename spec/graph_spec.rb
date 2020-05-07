# frozen_string_literal: true

# rspec spec/graph_spec.rb
RSpec.describe Graph do
  it "can be initialized without arguments" do
    expect(described_class.new).to be_a(described_class)
  end
end
