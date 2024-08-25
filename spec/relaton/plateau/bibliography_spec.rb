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
        .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
    end

    it "technical-report", vcr: "technical_report" do
      file = "spec/fixtures/technical_report.xml"
      bib = described_class.get("PLATEAU Technical Report #00")
      expect(bib).to be_instance_of Relaton::Plateau::BibItem
      xml = bib.to_xml bibdata: true
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
    end

    it "not found", vcr: "not_found" do
      expect { described_class.get("PLATEAU Handbook #") }.to output(
        including("[relaton-plateau] WARN: (PLATEAU Handbook #) Not found.")
      ).to_stderr_from_any_process
    end

    it "Handbook all editions", vcr: "handbook_all_editions" do
      bib = described_class.get("PLATEAU Handbook #00")
      expect(bib.docidentifier[0].id).to eq "PLATEAU Handbook #00"
      expect(bib.relation.size).to eq 4
      expect(bib.relation[0].type).to eq "hasEdition"
      expect(bib.relation[0].bibitem.docidentifier[0].id).to eq "PLATEAU Handbook #00 4.0"
    end

    it "Technical Report all editions", vcr: "technical_report_all_editions" do
      bib = described_class.get("PLATEAU Technical Report #00")
      expect(bib.docidentifier[0].id).to eq "PLATEAU Technical Report #00 1.0"
      expect(bib.relation.size).to eq 0
    end

    it "raise error" do
      expect(described_class).to receive(:search).and_raise(StandardError)
      expect { described_class.get("PLATEAU Handbook #00 第1.0版") }.to raise_error RelatonBib::RequestError
    end
  end
end
