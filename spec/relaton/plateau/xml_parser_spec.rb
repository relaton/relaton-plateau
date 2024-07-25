RSpec.describe Relaton::Plateau::XMLParser do
  let(:xml) do
    <<~XML
      <bibitem type="standard">
        <title language="en" format="text/plain">Title</title>
        <docidentifier>ISO 1</docidentifier>
        <ext>
          <doctype>article</doctype>
          <stagename abbreviation="SN">stage name</stagename>
          <cover>
            <image src="image/src" mimetype="image/jpeg"/>
          </cover>
          <filesize>123</filesize>
        </ext>
      </bibitem>
    XML
  end

  it "parse XML" do
    item = Relaton::Plateau::XMLParser.from_xml xml
    expect(item).to be_instance_of Relaton::Plateau::BibItem
    expect(item.title.first).to be_instance_of RelatonBib::TypedTitleString
    expect(item.docidentifier.first).to be_instance_of RelatonBib::DocumentIdentifier
    expect(item.doctype).to be_instance_of Relaton::Plateau::DocumentType
    expect(item.doctype.type).to eq "article"
    expect(item.stagename).to be_instance_of Relaton::Plateau::Stagename
    expect(item.stagename.content).to eq "stage name"
    expect(item.stagename.abbreviation).to eq "SN"
    expect(item.cover).to be_instance_of Relaton::Plateau::Cover
    expect(item.cover.image.src).to eq "image/src"
    expect(item.cover.image.mimetype).to eq "image/jpeg"
    expect(item.filesize).to eq 123
  end
end
