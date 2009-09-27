class InstallTheme::InstallThemeGenerator < RubiGen::Base
  # NOTE: runtime_options[:source] needs to be passed in to #new
  
  def manifest
    record do |m|
      files = Dir[File.join(source_root, "**/*")].map do |f|
        f.gsub(source_root, "").gsub(%r{^/}, '')
      end
      directories = files.map { |f| File.dirname(f) }.uniq.sort
      directories.each do |dir|
        m.directory dir
      end
      files.sort.each do |f|
        next if File.directory?(File.join(source_root, f))
        m.file f, f
      end
    end
  end
  
end