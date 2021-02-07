# frozen_string_literal: true

autoload(:Pathname, 'pathname')

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle::Directory, :'stibium/bundled/bundle/directory' do
  # @type [Class<Stibium::Bundled::Bundle::Directory>] described_class
  :new.tap do |method|
    it { expect(described_class).to respond_to(method).with(1).arguments }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:ruby_config) }
  end
end

# instance methods --------------------------------------------------
describe Stibium::Bundled::Bundle::Directory, :'stibium/bundled/bundle/directory' do
  # @type [Class<Stibium::Bundled::Bundle::Directory>] described_class
  # @type [Stibium::Bundled::Bundle::Directory] subject
  # @type [String] path
  let(:path) { __dir__.to_s }
  let(:subject) { described_class.new(path) }

  {
    path: Pathname,
    to_path: String,
    specifications: Array,
  }.each do |method, type|
    it { expect(subject).to respond_to(method).with(0).arguments }

    context "##{method}" do
      it { expect(subject.public_send(method)).to be_a(type) }
    end
  end

  context '#path' do
    it { expect(subject.path).to eq(Pathname.new(path)) }
  end

  [:to_s, :to_path].each do |method|
    context "##{method}" do
      it { expect(subject.public_send(method)).to eq(path) }
    end
  end
end
