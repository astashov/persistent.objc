Pod::Spec.new do |s|
  s.name         = "Persistent"
  s.version      = "0.1.1"
  s.summary      = "Persistent Data Structures"

  s.description  = <<-DESC
                   Persisent Vector, HashMap and Set for Objective-C
                   DESC

  s.homepage     = "http://github.com/astashov/persistent.objc"
  s.license      = "MIT"
  s.author             = { "Anton Astashov" => "anton.astashov@gmail.com" }
  s.source = { :git => "https://github.com/astashov/persistent.objc.git", :tag => "0.1.1" }
  s.source_files  = "Persistent/**/*.{h,m}"
  s.public_header_files = "Persistent/Headers/*.h"
  s.requires_arc = true
end
