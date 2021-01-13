# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Stibium::Bundled::Bundle, :'stibium/bundled/bundle' do
  [
    :Config,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end
end

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle, :'stibium/bundled/bundle' do
  # @type [Class<Stibium::Bundled::Bundle]>] described_class
  it { expect(described_class).to respond_to(:new).with(1).arguments }
end

# instance methods --------------------------------------------------
describe Stibium::Bundled::Bundle, :'stibium/bundled/bundle' do
  # @type [String] basedir
  # @type [Stibium::Bundled::Bundle] subject
  # @type [Class<Stibium::Bundled::Bundle]>] described_class
  let(:basedir) { __dir__ }
  let(:subject) { described_class.new(basedir) }

  [:bundled?,
   :to_path,
   :locked?,
   :gemfile,
   :gemfiles,
   :standalone?,
   :standalone!,
   :config,].each do |method|
     it { expect(subject).to respond_to(method).with(0).arguments }
   end
end

# tests -------------------------------------------------------------
describe Stibium::Bundled::Bundle, :'stibium/bundled/bundle' do
  # @type [String] basedir
  # @type [Stibium::Bundled::Bundle] subject
  # @type [Class<Stibium::Bundled::Bundle]>] described_class
  let(:basedir) { __dir__ }
  let(:subject) { described_class.new(basedir) }

  it { expect(subject).to be_frozen }

  context '#path' do
    it { expect(subject.path).to be_frozen }

    it do
      expect(subject.path).to be_a(Pathname)
      expect(subject.path).to eq(Pathname.new(basedir))
    end
  end

  context '#to_path' do
    it { expect(subject.to_path).to be_a(String) }
    it { expect(subject.to_path).to eq(basedir) }
  end

  context '#config' do
    it { expect(subject.config).to be_a(Hash) }
    it { expect(subject.config).to be_frozen }
  end
end
