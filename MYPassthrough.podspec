Pod::Spec.new do |s|
  s.name         = "MYPassthrough"
  s.version      = "0.6"
  s.summary      = "Framework that helps you to guide the user through your application, step by step."
  s.description  = <<-DESC
                    With the help of this framework, it will be easier for you to solve such tasks: guide, tutorial, help, onboarding
                   DESC
  s.homepage     = "https://github.com/PetecOvod/MYPassthrough"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Yaroslav Minaev" => "mail@minaev.pro" }
  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.source       = {
    :git => 'https://github.com/PetecOvod/MYPassthrough.git',
    :tag => s.version }
  s.source_files  = 'Source/*.swift'
end
