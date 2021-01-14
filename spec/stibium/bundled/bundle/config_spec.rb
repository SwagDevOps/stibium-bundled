# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle::Config, :'stibium/bundled/bundle/config' do
  # @type [Class<Stibium::Bundled::Bundle::Config]>] described_class
  :new.tap do |method|
    it { expect(described_class).to respond_to(method).with(1).arguments }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:env) }
  end
end
