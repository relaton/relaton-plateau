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

  it "parse" do
    expect(subject).to receive(:parse_docid).and_call_original
    expect(subject).to receive(:parse_title).and_return :title
    expect(subject).to receive(:parse_abstract).and_call_original
    expect(subject).to receive(:parse_cover).and_return :cover
    expect(subject).to receive(:parse_edition).and_return :edition
    expect(subject).to receive(:parse_type).and_call_original
    expect(subject).to receive(:parse_doctype).and_call_original
    expect(subject).to receive(:parse_subdoctype).and_call_original
    expect(subject).to receive(:parse_date).and_call_original
    expect(subject).to receive(:parse_link).and_call_original
    expect(subject).to receive(:parse_filesize).and_return 123
    expect(subject).to receive(:parse_keyword).and_call_original
    expect(subject).to receive(:parse_structuredidentifier).and_return :stridcol
    expect(Relaton::Plateau::BibItem).to receive(:new).with(
      docid: [], title: :title, abstract: [], cover: :cover, edition: :edition,
      type: "standard", doctype: nil, subdoctype: nil, date: [], link: [],
      filesize: 123, keyword: [], structuredidentifier: :stridcol
    ).and_return :bibitem
    expect(subject.parse).to be :bibitem
  end

  it "parse_docid" do
    expect(subject.send(:parse_docid)).to eq []
  end

  it "create_docid" do
    docid = subject.send(:create_docid, "id")
    expect(docid).to be_instance_of RelatonBib::DocumentIdentifier
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
