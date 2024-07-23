RSpec.describe Relaton::Plateau::HandbookParser do
  let(:version) do
    {
      "title" => "1.0",
      "date" => "2020.01.01",
      "pdf" => "https://example.com/1.0.pdf",
      "html" => "https://example.com/1.0.html",
      "filesize" => 123
    }
  end

  let(:entry) do
    {
      "slug" => "slug",
      "handbook" => {
        "title" => "title",
        "thumbnail" => { "mediaItemUrl" => "thumbnail" },
        "description" => "title\nabstract"
      }
    }
  end

  let(:title_en) { "title" }
  let(:abstract) { "abstract" }
  let(:doctype) { "handbook" }
  subject do
    Relaton::Plateau::HandbookParser.new(
      version: version, entry: entry, title_en: title_en, abstract: abstract, doctype: doctype
    )
  end

  it "creates handbook" do
    expect(subject.instance_variable_get(:@version)).to be version
    expect(subject.instance_variable_get(:@entry)).to be entry
    expect(subject.instance_variable_get(:@item)).to be entry["handbook"]
    expect(subject.instance_variable_get(:@title_en)).to eq title_en
    expect(subject.instance_variable_get(:@abstract)).to eq abstract
    expect(subject.instance_variable_get(:@doctype)).to eq doctype
  end

  it "parse_docid" do
    docid = subject.send :parse_docid
    expect(docid).to be_instance_of Array
    expect(docid.size).to eq 1
    expect(docid[0]).to be_instance_of RelatonBib::DocumentIdentifier
    expect(docid[0].id).to eq "PLATEAU Handbook #slug 1.0"
    expect(docid[0].type).to eq "PLATEAU"
    expect(docid[0].primary).to be true
  end

  it "parse_title" do
    title = subject.send :parse_title
    expect(title).to be_instance_of Array
    expect(title.size).to eq 2
    expect(title[0]).to be_instance_of RelatonBib::TypedTitleString
    expect(title[0].title.content).to eq "title"
    expect(title[0].title.language).to eq ["ja"]
    expect(title[0].title.script).to eq ["Jpan"]
    expect(title[1]).to be_instance_of RelatonBib::TypedTitleString
    expect(title[1].title.content).to eq "title"
    expect(title[1].title.language).to eq ["en"]
    expect(title[1].title.script).to eq ["Latn"]
  end

  it "parse_abstract" do
    abstract = subject.send :parse_abstract
    expect(abstract).to be_instance_of Array
    expect(abstract.size).to eq 1
    expect(abstract[0]).to be_instance_of RelatonBib::FormattedString
    expect(abstract[0].content).to eq "abstract"
    expect(abstract[0].language).to eq ["ja"]
    expect(abstract[0].script).to eq ["Jpan"]
  end

  it "parse_edition" do
    edition = subject.send :parse_edition
    expect(edition).to be_instance_of RelatonBib::Edition
    expect(edition.content).to eq "1.0"
    expect(edition.number).to eq "1.0"
  end

  it "parse_doctype" do
    doctype = subject.send :parse_doctype
    expect(doctype).to be_instance_of RelatonBib::DocumentType
    expect(doctype.type).to eq "handbook"
  end

  it "parse_date" do
    date = subject.send :parse_date
    expect(date).to be_instance_of Array
    expect(date.size).to eq 1
    expect(date[0]).to be_instance_of RelatonBib::BibliographicDate
    expect(date[0].type).to eq "published"
    expect(date[0].on).to eq "2020-01-01"
  end

  it "parse_link" do
    link = subject.send :parse_link
    expect(link).to be_instance_of Array
    expect(link.size).to eq 2
    expect(link[0]).to be_instance_of RelatonBib::TypedUri
    expect(link[0].content.to_s).to eq "https://example.com/1.0.pdf"
    expect(link[0].type).to eq "pdf"
    expect(link[1]).to be_instance_of RelatonBib::TypedUri
    expect(link[1].content.to_s).to eq "https://example.com/1.0.html"
    expect(link[1].type).to eq "html"
  end

  it "parse_filesize" do
    expect(subject.send(:parse_filesize)).to eq 123
  end

  it "parse_structuredidentifier" do
    strid = subject.send :parse_structuredidentifier
    expect(strid).to be_instance_of RelatonBib::StructuredIdentifierCollection
    expect(strid[0]).to be_instance_of RelatonBib::StructuredIdentifier
    expect(strid[0].type).to eq "Handbook"
    expect(strid[0].agency).to eq ["PLATEAU"]
    expect(strid[0].docnumber).to eq "slug"
    expect(strid[0].edition).to eq "1.0"
  end
end
