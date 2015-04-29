Gem::Specification.new do |s|
	s.name        = 'async_tcpsocket'
	s.version     = '1.0.0'
	s.date        = '2015-04-29'
	s.summary     = "AsyncTCPServer"
	s.description = "An asyncronous tcp socket for ruby"
	s.authors     = ["Greg Martin"]
	s.email       = 'greg@softsprocket.com'
	s.files       = ["lib/async_tcpsocket.rb"]
	s.homepage    = 'http://rubygems.org/gems/async_tcpsocket.rb'
	s.license     = 'MIT'
	s.add_runtime_dependency "async_emitter", '~> 1.1', '>= 1.1.1'
end

