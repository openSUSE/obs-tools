require 'octokit'
require 'logger'
require 'yaml'
require_relative 'lib/obs_pull_request_package'
require_relative 'lib/github_status_reporter'

config = YAML.load_file('config/config.yml')
client = Octokit::Client.new(config[:credentials])
logger = Logger.new(STDOUT)
 
def line_seperator(pull_request)
  '=' * 15 + " #{pull_request.title} (#{pull_request.number}) " + '=' * 15
end

new_packages = []
client.pull_requests('openSUSE/open-build-service').each do |pull_request|
  next if pull_request.updated_at < (Date.today - 7).to_time || pull_request.base.ref != 'master'

  logger.info('')
  logger.info(line_seperator(pull_request))
  package = ObsPullRequestPackage.new(pull_request: pull_request, logger: logger)
  package.create
  
  GitHubStatusReporter.new(package: package, client: client, logger: logger).report
  new_packages << package
end

ObsPullRequestPackage.all(logger).each do |obs_package|
  next if new_packages.any? { |pr_package| pr_package.pull_request.number == obs_package.pull_request.number }
  obs_package.delete
end
