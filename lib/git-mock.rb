require "tmpdir"

module GitMock
  module Git
    DEFAULT_INITIAL_BRANCH = 'master'

    class Mock
      def initialize(initial_branch=nil, branches=[])
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do 
            branches.delete(initial_branch)
            branches.uniq!
            repo_initialized = Git.initialize(initial_branch)
            `git commit --allow-empty --allow-empty-message -m ""`
            commit_successful = $?.success?
            Git.make_branches(branches)
    
            meta = { 
              initial_branch: initial_branch,
              branches: [initial_branch] + branches,
              initialized: repo_initialized && commit_successful
            }
    
            yield meta
          end
        end
      end
    end

    def self.initialize(initial_branch=nil)
      system('git', 'init', '-b', initial_branch || DEFAULT_INITIAL_BRANCH)
      return $?.success?
    end

    def self.make_branch(branch)
      system('git', 'branch', branch)
    end

    def self.make_branches(branches)
      for branch in branches
        Git.make_branch(branch)
      end
    end

    def self.get_current_branch()
      return `git branch --show-current`.chomp
    end

    def self.get_commit_count()
      return Integer(`git rev-list --count HEAD`)
    end

    def self.get_branch_names()
      return `git branch --format "%(refname:short)"`.each_line.map(&:chomp)
    end

    def self.commit_all(msg='')
      results = []
      `git add .`
      results.append($?.success?)
      system('git', 'commit', '--allow-empty-message', '-m', msg)
      results.append($?.success?)
      return results.all?
    end
  end
end