# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Stibium::Bundled::Bundle::Config, :'stibium/bundled/bundle/config' do
  [
    :Reader,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end
end

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle::Config, :'stibium/bundled/bundle/config' do
  # @type [Class<Stibium::Bundled::Bundle::Config>] described_class
  :new.tap do |method|
    it { expect(described_class).to respond_to(method).with(1).arguments }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:env) }
  end

  context '.defaults' do
    let(:expected) do
      {
        'BUNDLE_APP_CONFIG' => '.bundle',
        'BUNDLE_PATH' => 'bundle'
      }
    end

    it { expect(described_class.defaults).to eq(expected) }
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

# samples -----------------------------------------------------------
sham!(:'samples/configs').lister.call.each do |_, sample|
  # @type [Class<Stibium::Bundled::Bundle::Config>] described_class
  # @type [Stibium::Bundled::Bundle::Config] subject
  describe Stibium::Bundled::Bundle::Config, :'stibium/bundled/bundle/config', :samples do
    let(:subject) { described_class.new(sample.basedir, env: sample.env) }
    let(:expected) { sample.result }

    context ".new(#{sample.basedir.to_s.inspect}, env: #{sample.env})" do
      it { expect(subject).to eq(expected) }
    end
  end
end
