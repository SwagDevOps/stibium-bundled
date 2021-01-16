# frozen_string_literal: true

lister = lambda do
  Dir.glob("#{SAMPLES_PATH}/configs/*/env.rb").map { |fp| Pathname.new(fp) }.keep_if(&:file?).map do |fp|
    [
      fp.dirname.basename.to_s.to_sym,
      {
        env: self.instance_eval(fp.read, fp.to_s, 0).to_h.sort.to_h,
        basedir: fp.dirname,
      }.yield_self { |h| Struct.new(*h.keys).new(*h.values) }
    ]
  end.to_h
end

{
  lister: lister,
}
