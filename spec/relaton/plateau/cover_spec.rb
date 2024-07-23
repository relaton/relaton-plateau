RSpec.describe Relaton::Plateau::Cover do
  let(:image) { RelatonBib::Image.new src: "image/src", mimetype: "image/jpeg" }
  subject { described_class.new image }

  it "creates cover" do
    expect(subject.image).to be image
  end

  it "to_xml" do
    builder = Nokogiri::XML::Builder.new
    subject.to_xml builder
    expect(builder.doc.root.to_xml).to be_equivalent_to <<~XML
      <cover>
        <image src="image/src" mimetype="image/jpeg"/>
      </cover>
    XML
  end

  it "to_hash" do
    expect(subject.to_hash).to eq image.to_hash
  end

  it "to_asciibib" do
    expect(subject.to_asciibib).to eq <<~ASCIIBIB
      cover.image.src:: image/src
      cover.image.mimetype:: image/jpeg
    ASCIIBIB
  end
end
