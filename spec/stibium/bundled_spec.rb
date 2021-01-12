# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Stibium::Bundled, :'stibium/bundled' do
  [
    :Bundle,
    :VERSION,
  ].each do |k|
    it { expect(described_class).to be_const_defined(k) }
  end

  it do
    lambda do
      require 'kamaze/version'

      Kamaze::Version
    end.call.tap do |klass|
      expect(described_class.const_get(:VERSION)).to be_a(klass)
    end
  end
end

# class methods -----------------------------------------------------
describe Stibium::Bundled, :'stibium/bundled' do
  :call.tap do |method|
    it { expect(described_class).to respond_to(method) }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:basedir) }
  end
end

# included ----------------------------------------------------------
describe sham!(:bundled).builder.call, :'stibium/bundled' do
  it { expect(described_class).to be_a(Stibium::Bundled) }

  :bundled_from.tap do |method|
    context '.methods' do
      it { expect(described_class.methods).to include(method) }
      it { expect(described_class.public_methods).not_to include(method) }
    end
  end
end
