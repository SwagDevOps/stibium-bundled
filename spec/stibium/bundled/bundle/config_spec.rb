# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle::Config, :'stibium/bundled/bundle/config' do
  # @type [Class<Stibium::Bundled::Bundle::Config>] described_class
  :new.tap do |method|
    it { expect(described_class).to respond_to(method).with(1).arguments }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:env) }
  end
end

# attributes --------------------------------------------------------
describe Stibium::Bundled::Bundle::Config, :'stibium/bundled/bundle/config' do
  # @type [Class<Stibium::Bundled::Bundle::Config>] described_class
  # @type [Stibium::Bundled::Bundle::Config] subject
  # @type [Pathname] basedir
  let(:basedir) { Pathname.new(__dir__) }
  let(:subject) { described_class.new(basedir, env: {}) }

  {
    env: Hash,
    basedir: Pathname,
  }.each do |method, type|
    it { expect(subject).to respond_to(method).with(0).arguments }

    context "##{method}" do
      it { expect(subject.public_send(method)).to be_a(type) }
      it { expect(subject.public_send(method)).to be_frozen }

      if :basedir == method.to_sym
        it { expect(subject.basedir).to eq(basedir) }
      end
    end
  end
end
