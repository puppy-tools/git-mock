require "minitest/autorun"
require "minitest/pride"
require "git-mock"
require "tmpdir"



module GitMockTestUtils 
  def self.mktmpdir(&block)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do block.call end
    end
  end
end

module GitMockTest
  Git = GitMock::Git
  Utils = GitMockTestUtils

  DEFAULT_INITIAL_BRANCH = Git::DEFAULT_INITIAL_BRANCH

  class InitializeRepo < Minitest::Test
    def _impl_test_initialize(expected, &fn)
      Utils.mktmpdir do
        
        assert(fn.call)
        assert_equal(expected, `git branch --show-current`.chomp)
        assert(Dir.exist? '.git')
      end
    end
  
    def test_initialize_repo_default() 
      _impl_test_initialize(DEFAULT_INITIAL_BRANCH) do 
        Git.initialize_repo_default
      end
    end
    
    def test_initialize_repo() 
      name = 'main'
      _impl_test_initialize(name) do 
        Git.initialize_repo(name) 
      end
    end
  end
end