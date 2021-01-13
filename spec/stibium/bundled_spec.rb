# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Stibium::Bundled, :'stibium/bundled' do
  [
    :Bundle,
    :VERSION,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
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
sham!(:bundled).builder.tap do |builder|
  describe builder.call, :'stibium/bundled' do
    it { expect(described_class).to be_a(Stibium::Bundled) }

    { bundled: nil, bundled?: false }.each do |method, value|
      it { expect(described_class).to respond_to(method).with(0).arguments }
      context ".#{method}" do
        it { expect(described_class.__send__(method)).to eq(value) }
      end
    end

    :bundled_from.tap do |method|
      context '.methods' do
        it { expect(described_class.methods).to include(method) }
      end

      context '.public_methods' do
        it { expect(described_class.public_methods).not_to include(method) }
      end

      it do
        # pass method public
        described_class.clone.dup.tap do |c|
          c.singleton_class.instance_eval { public method.to_sym }
        end.tap { |c| expect(c).to respond_to(method).with(1).arguments }
      end
    end
  end
end

# samples -----------------------------------------------------------
sham!(:samples).lister.call.map { |k, _| [k, sham!(:samples).builder.call(k)] }.to_h.each do |_, c|
  describe c, :'stibium/bundled', :samples do
    it { expect(described_class).to be_a(Stibium::Bundled) }

    { bundled: [NilClass, Stibium::Bundled::Bundle], bundled?: [TrueClass, FalseClass] }.each do |method, types|
      it { expect(described_class).to respond_to(method).with(0).arguments }

      context ".#{method}.class" do
        it do
          expect(described_class.__send__(method).class).to satisfy("be in #{types}") { |x| types.include?(x) }
        end
      end
    end
  end
end

{
  empty: [FalseClass, NilClass],
  gemfile: [TrueClass, Stibium::Bundled::Bundle],
  gemfile_old: [TrueClass, Stibium::Bundled::Bundle],
  partial: [FalseClass, NilClass],
  partial_old: [FalseClass, NilClass],
  standalone: [TrueClass, Stibium::Bundled::Bundle]
}.sort.each do |name, types|
  sham!(:samples).builder.call(name).tap do |c|
    describe c, :'stibium/bundled', :samples do
      context '.bundled?' do
        it { expect(described_class.bundled?).to be_a(types.fetch(0)) }
      end

      context '.bundled' do
        it { expect(described_class.bundled).to be_a(types.fetch(1)) }
      end
    end
  end
end
