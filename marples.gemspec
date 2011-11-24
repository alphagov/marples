# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "marples/version"

Gem::Specification.new do |s|
  s.name        = "marples"
  s.version     = Marples::VERSION
  s.authors     = ["Craig R Webster", "Dafydd Vaughan"]
  s.email       = ["craig@barkingiguana.com", "dai@daibach.co.uk"]
  s.homepage    = ""
  s.summary     = %q{Message destination arbiter}
  s.description = %q{Message destination arbiter}
  s.rubyforge_project = "marples"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "null_logger"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency 'i18n'
end
