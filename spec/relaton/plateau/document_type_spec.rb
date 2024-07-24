RSpec.describe Relaton::Plateau::DocumentType do
  it "creates document type" do
    expect { described_class.new type: "handbook" }.not_to raise_error
  end

  it "creates document type with abbreviation" do
    expect { described_class.new type: "handbook", abbreviation: "HB" }.not_to raise_error
  end

  it "creates document type with invalid type" do
    expect { described_class.new type: "invalid" }.to output(
      "[relaton-plateau] WARN: invalid doctype: `invalid`\n"
    ).to_stderr_from_any_process
  end
end
