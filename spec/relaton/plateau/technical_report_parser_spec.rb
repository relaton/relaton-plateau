RSpec.describe Relaton::Plateau::TechnicalReportParser do
  let(:entry) do
    {
      "id" => "cG9zdDo4Mzcz",
      "date" => "2024-03-29T10:00:29",
      "slug" => "93",
      "technicalReport" => {
        "title" => "歴史・文化・営みを継承するメタバース体験の構築 技術検証レポート",
        "subtitle" => "歴史・文化・営みを継承するメタバース体験の構築の技術資料 (2023年度)",
        "thumbnail" => {
          "mediaItemUrl" => "/plateau/uploads/2024/03/plateau_tech_doc_0093_ver01.jpg",
          "mediaDetails" => { "width" => 1275, "height" => 1650 }
        },
        "pdf" => "https://www.mlit.go.jp/plateau/file/libraries/doc/plateau_tech_doc_0093_ver01.pdf",
        "filesize" => "22005029"
      },
      "technicalReportCategories" => { "nodes" => [{ "name" => "Use Case", "slug" => "usecase" }] },
      "usecaseFields" => {"nodes" => [{ "name" => "地域活性化・観光", "slug" => "regional-activation_sightseeing" }] },
      "globalTags" => {
        "nodes" => [
          { "name" => "Unreal Engine", "slug" => "unreal_engine" },
          { "name" => "デジタルツイン", "slug" => "digital-twin" },
          { "name" => "Unity", "slug" => "unity" },
          { "name" => "AR/VR", "slug" => "ar_vr" }
        ]
      }
    }
  end

  subject { described_class.new entry }

  it "creates technical report" do
    expect(subject.instance_variable_get(:@entry)).to be entry
    expect(subject.instance_variable_get(:@item)).to be entry["technicalReport"]
  end

  it "parse_docid" do
    docid = subject.send :parse_docid
    expect(docid).to be_instance_of Array
    expect(docid.size).to eq 1
    expect(docid[0]).to be_instance_of RelatonBib::DocumentIdentifier
    expect(docid[0].id).to eq "PLATEAU Technical Report #93"
    expect(docid[0].type).to eq "PLATEAU"
    expect(docid[0].primary).to be true
  end

  it "parse_abstract" do
    abstract = subject.send :parse_abstract
    expect(abstract).to be_instance_of Array
    expect(abstract.size).to eq 1
    expect(abstract[0]).to be_instance_of RelatonBib::FormattedString
    expect(abstract[0].content).to eq "歴史・文化・営みを継承するメタバース体験の構築の技術資料 (2023年度)"
  end

  it "parse_edition" do
    edition = subject.send :parse_edition
    expect(edition).to be_instance_of RelatonBib::Edition
    expect(edition.content).to eq "1.0"
    expect(edition.number).to eq "1.0"
  end

  it "parse_doctype" do
    doctype = subject.send :parse_doctype
    expect(doctype).to be_instance_of Relaton::Plateau::DocumentType
    expect(doctype.type).to eq "technical-report"
  end

  it "parse_subdoctype" do
    subdoctype = subject.send :parse_subdoctype
    expect(subdoctype).to eq "Use Case"
  end

  it "parse_date" do
    date = subject.send :parse_date
    expect(date).to be_instance_of Array
    expect(date.size).to eq 1
    expect(date[0]).to be_instance_of RelatonBib::BibliographicDate
    expect(date[0].on).to eq "2024-03-29"
  end

  it "parse_link" do
    link = subject.send :parse_link
    expect(link).to be_instance_of Array
    expect(link.size).to eq 1
    expect(link[0]).to be_instance_of RelatonBib::TypedUri
    expect(link[0].content.to_s).to eq(
      "https://www.mlit.go.jp/plateau/file/libraries/doc/plateau_tech_doc_0093_ver01.pdf"
    )
    expect(link[0].type).to eq "pdf"
  end

  it "parse_filesize" do
    expect(subject.send(:parse_filesize)).to eq 22005029
  end

  it "parse_keyword" do
    keyword = subject.send :parse_keyword
    expect(keyword).to be_instance_of Array
    expect(keyword.size).to eq 4
    expect(keyword[0]).to eq "Unreal Engine"
  end

  it "parse_structuredidentifier" do
    strid = subject.send :parse_structuredidentifier
    expect(strid).to be_instance_of RelatonBib::StructuredIdentifierCollection
    expect(strid[0]).to be_instance_of RelatonBib::StructuredIdentifier
    expect(strid[0].type).to eq "Technical Report"
    expect(strid[0].klass).to eq "Use Case"
    expect(strid[0].agency).to eq ["PLATEAU"]
    expect(strid[0].docnumber).to eq "93"
  end
end
