

namespace :extra_cmds do
  task :create_version_file do
    on "#{deploy_config['user']}@#{deploy_config['host']}:#{deploy_config['port']}" do
      execute "(cd /tmp; git clone --bare #{fetch(:repo_url)} tmp1234 2> /dev/null ; cd tmp1234; git log -1 > \"#{fetch(:deploy_to)}/current/last_commit.txt\"; cd ..; rm -Rf tmp1234)"
    end
  end
end