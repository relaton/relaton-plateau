RSpec.describe Relaton::Plateau::Bibliography do
  before do
    # Force to download index file
    allow_any_instance_of(Relaton::Index::Type).to receive(:actual?).and_return(false)
    allow_any_instance_of(Relaton::Index::FileIO).to receive(:check_file).and_return(nil)
  end

  context "get" do
    it "handbook", vcr: "handbook" do
      file = "spec/fixtures/handbook.xml"
      bib = described_class.get("PLATEAU Handbook #00 1.0")
      expect(bib).to be_instance_of Relaton::Plateau::BibItem
      xml = bib.to_xml bibdata: true
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end

    it "technical-report", vcr: "technical_report" do
      file = "spec/fixtures/technical_report.xml"
      bib = described_class.get("PLATEAU Technical Report #00")
      expect(bib).to be_instance_of Relaton::Plateau::BibItem
      xml = bib.to_xml bibdata: true
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end

    it "not found", vcr: "not_found" do
      expect { described_class.get("PLATEAU Handbook #03") }.to output(
        including("[relaton-plateau] WARN: (PLATEAU Handbook #03) Not found.")
      ).to_stderr_from_any_process
    end

    it "raise error" do
      expect(described_class).to receive(:search).and_raise(StandardError)
      expect { described_class.get("PLATEAU Handbook #00 第1.0版") }.to raise_error RelatonBib::RequestError
    end
  end
end
