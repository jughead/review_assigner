require File.expand_path('lib/review_assigner/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'review_assigner'
  s.version     = ReviewAssigner::VERSION
  s.date        = '2017-04-01'
  s.summary     = "Review assigner for experts according to given excel file"
  s.description = "An optimal expert-to-object review assigner. Reads and writes result in excel format."
  s.authors     = ["Alexander Fedulin"]
  s.email       = 'alexander.fedulin@gmail.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'https://github.com/jughead/review_assigner'
  s.license     = 'MIT'
  s.executables << 'review_assigner'
  s.add_dependency 'roo'
  s.add_dependency 'axlsx'
end
