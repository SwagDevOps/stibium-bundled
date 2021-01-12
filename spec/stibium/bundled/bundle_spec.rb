# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle, :'stibium/bundled/bundle' do
  it { expect(described_class).to respond_to(:new).with(1).arguments }
end

# instance methods --------------------------------------------------
describe Stibium::Bundled::Bundle, :'stibium/bundled/bundle' do
  let(:subject) { described_class.new(__dir__) }

  [:bundled?, :to_path, :locked?, :gemfile, :gemfiles, :standalone?, :standalone!].each do |method|
    it { expect(subject).to respond_to(method).with(0).arguments }
  end
end
