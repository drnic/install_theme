Spec::Matchers.define :have_same_contents_as do |expected_file|
  diffable
  
  match do |actual_root_path|
    puts expected = File.read(expected_file)
    false
  end
  
  description do
    "match the file in the two projects"
  end
end

Spec::Matchers.define :have_same_basename do |expected|
  match do |actual|
    File.basename(expected) == File.basename(actual)
  end
end
