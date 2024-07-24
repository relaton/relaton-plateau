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
    expect(bib[:ext][:stagename]).to be_instance_of Relaton::Plateau::Stagename
    expect(bib[:ext][:stagename].content).to eq "Stage Name"
    expect(bib[:ext][:stagename].abbreviation).to eq "SN"
    expect(bib[:ext][:filesize]).to eq 10
    expect(bib[:ext][:cover]).to be_instance_of Relaton::Plateau::Cover
    expect(bib[:ext][:cover].image.src).to eq "path/image.jpg"
    expect(bib[:ext][:cover].image.mimetype).to eq "image/jpeg"
  end
end
