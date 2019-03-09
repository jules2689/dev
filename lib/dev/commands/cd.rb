# TODO: Test
require 'dev'

module Dev
  module Commands
    class Cd < Dev::Command
      def call(args, _name)
        url = Dev::Helpers::Git::Url.new(args.shift)
        query = File.join(url.org_or_user, url.repo_name)

        # This find command will enumerate the ~/src directory for all repos
        # Assumes ~/src/PROVIDER.com/OWNER/REPO
        # Will return all `REPO` entries relative to the src path
        base_path = File.expand_path('~/src')
        options = Dev::Helpers::Fzy.fuzzy_match(
          "find #{base_path}/*/* -type d -maxdepth 1 -mindepth 1 | sed -n 's|^#{base_path}||p'",
          query: query,
          num_matches: 1
        )

        if options.empty?
          puts "Nothing found for #{args.first}"
        else
          path = File.join(base_path, options.first)
          Dev::FILE_DESCRIPTOR.write("cd #{path}")
        end
      end

      def self.help
        <<~EOF
          Change Directory to Repository. Uses Fuzzy Matching.
          Usage: {{command:#{Dev::TOOL_NAME} cd dev}}
        EOF
      end
    end
  end
end
