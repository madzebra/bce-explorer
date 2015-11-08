task default: :sync

namespace :db do
  LOCKFILE = '/tmp/bce-explorer.lock'

  def run_with_lock(script)
    return if File.exist? LOCKFILE
    begin
      mode = ::File::CREAT | ::File::EXCL | ::File::WRONLY
      File.open(LOCKFILE, mode) { |f| f.write '1' }
      ruby script
    ensure
      File.delete LOCKFILE
    end
  end

  task :sync do
    run_with_lock './tasks/db_sync.rb'
  end

  task :index do
    run_with_lock './tasks/db_index.rb'
  end
end
