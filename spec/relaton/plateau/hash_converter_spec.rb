RSpec.describe Relaton::Plateau::HashConverter do
  let(:hash) do
    {
      "title" => [{ "type" => "main", "content" => "Title" }],
      "docid" => [{ "id" => "PLATEAU Handbook #01", "type" => "PLATEAU" }],
      "ext" => {
        "stagename" => { "content" => "Stage Name", "abbreviation" => "SN" },
        "filesize" => "10",
        "cover" => { "image" => { "src" => "path/image.jpg", "mimetype" => "image/jpeg" } }
      }
    }
  end

  it "converts hash to bib" do
    bib = described_class.hash_to_bib hash
    expect(bib[:title].first).to be_instance_of RelatonBib::TypedTitleString
    expect(bib[:docid].first).to be_instance_of RelatonBib::DocumentIdentifier
    expect(bib[:stagename]).to be_instance_of Relaton::Plateau::Stagename
    expect(bib[:stagename].content).to eq "Stage Name"
    expect(bib[:stagename].abbreviation).to eq "SN"
    expect(bib[:filesize]).to eq 10
    expect(bib[:cover]).to be_instance_of Relaton::Plateau::Cover
    expect(bib[:cover].image.src).to eq "path/image.jpg"
    expect(bib[:cover].image.mimetype).to eq "image/jpeg"
  end

  it "bib_item" do
    bib = described_class.bib_item title: [{ type: "main", content: "Title" }]
    expect(bib).to be_instance_of Relaton::Plateau::BibItem
  end

  it "create_doctype" do
    doctype = described_class.create_doctype type: "Handbook"
    expect(doctype).to be_instance_of Relaton::Plateau::DocumentType
  end
end
