RSpec.describe Relaton::Plateau::Parser do
  let(:item) do
    {
      "title" => "Title",
      "thumbnail" => { "mediaItemUrl" => "/plateau/uploads/2022/06/1@2x.jpg" }
    }
  end

  subject { described_class.new item }

  it "creates parser" do
    expect(subject.instance_variable_get(:@item)).to be item
  end

  it "parse_docid" do
    expect(subject.send(:parse_docid)[0]).to be_instance_of Relaton::Plateau::Docidentifier
  end

  it "create_docid" do
    docid = subject.send(:create_docid, "id")
    expect(docid).to be_instance_of Relaton::Plateau::Docidentifier
    expect(docid.type).to eq "PLATEAU"
    expect(docid.id).to eq "id"
    expect(docid.primary).to be true
  end

  it "create_formatted_string" do
    fs = subject.send(:create_formatted_string, "content", "en", "Latn")
    expect(fs).to be_instance_of RelatonBib::FormattedString
    expect(fs.content).to eq "content"
    expect(fs.language).to eq ["en"]
    expect(fs.script).to eq ["Latn"]
  end

  it "parse_title" do
    title = subject.send(:parse_title)
    expect(title).to be_instance_of Array
    expect(title.size).to eq 1
    expect(title.first).to be_instance_of RelatonBib::TypedTitleString
    expect(title.first.type).to eq "main"
    expect(title.first.title.content).to eq "Title"
    expect(title.first.title.language).to eq ["ja"]
    expect(title.first.title.script).to eq ["Jpan"]
  end

  it "parse_abstract" do
    expect(subject.send(:parse_abstract)).to eq []
  end

  it "parse_cover" do
    cover = subject.send(:parse_cover)
    expect(cover).to be_instance_of Relaton::Plateau::Cover
    expect(cover.image).to be_instance_of RelatonBib::Image
    expect(cover.image.src).to eq "https://www.mlit.go.jp//plateau/uploads/2022/06/1@2x.jpg"
    expect(cover.image.mimetype).to eq "image/jpeg"
  end

  it "parse_edition" do
    expect { subject.send(:parse_edition) }.to raise_error "Not implemented"
  end

  it "parse_type" do
    expect(subject.send(:parse_type)).to eq "standard"
  end

  it "parse_doctype" do
    expect(subject.send(:parse_doctype)).to be_nil
  end

  it "parse_subdoctype" do
    expect(subject.send(:parse_subdoctype)).to be_nil
  end

  it "parse_date" do
    expect(subject.send(:parse_date)).to eq []
  end

  it "create_date" do
    date = subject.send(:create_date, "2022-06-01")
    expect(date).to be_instance_of RelatonBib::BibliographicDate
    expect(date.type).to eq "published"
    expect(date.on).to eq "2022-06-01"
  end

  it "parse_link" do
    expect(subject.send(:parse_link)).to eq []
  end

  it "create_link" do
    link = subject.send(:create_link, "http://example.com", "pdf")
    expect(link).to be_instance_of RelatonBib::TypedUri
    expect(link.content.to_s).to eq "http://example.com"
    expect(link.type).to eq "pdf"
  end

  it "parse_contributor" do
    contrib = subject.send(:parse_contributor)
    expect(contrib).to be_instance_of Array
    expect(contrib.size).to eq 1
    expect(contrib.first).to be_instance_of RelatonBib::ContributionInfo
    expect(contrib.first.entity).to be_instance_of RelatonBib::Organization
    expect(contrib.first.entity.name.size).to eq 2
    expect(contrib.first.entity.name.first.content).to eq "国土交通省"
    expect(contrib.first.entity.name.first.language).to eq ["ja"]
    expect(contrib.first.entity.name.first.script).to eq ["Jpan"]
    expect(contrib.first.entity.name.last.content).to eq(
      "Japanese Ministry of Land, Infrastructure, Transport and Tourism"
    )
    expect(contrib.first.entity.name.last.language).to eq ["en"]
    expect(contrib.first.entity.name.last.script).to eq ["Latn"]
  end

  it "parse_filesize" do
    expect { subject.send(:parse_filesize) }.to raise_error "Not implemented"
  end

  it "parse_keyword" do
    expect(subject.send(:parse_keyword)).to eq []
  end

  it "parse_structuredidentifier" do
    expect { subject.send(:parse_structuredidentifier) }.to raise_error "Not implemented"
  end
end
