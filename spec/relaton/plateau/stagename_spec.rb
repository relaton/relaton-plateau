RSpec.describe Relaton::Plateau::Stagename do
  let(:stagename) { described_class.new content: "stage name", abbreviation: "abbr" }

  it "creates stagename" do
    expect(stagename.content).to eq "stage name"
    expect(stagename.abbreviation).to eq "abbr"
  end

  it "to_xml" do
    builder = Nokogiri::XML::Builder.new
    stagename.to_xml builder
    expect(builder.doc.root.to_xml).to be_equivalent_to <<~XML
      <stagename abbreviation="abbr">stage name</stagename>
    XML
  end

  it "to_hash" do
    expect(stagename.to_hash).to eq(content: "stage name", abbreviation: "abbr")
  end

  it "to_asciibib" do
    expect(stagename.to_asciibib).to eq <<~ASCIIBIB
      stagename.content:: stage name
      stagename.abbreviation:: abbr
    ASCIIBIB
  end
end
