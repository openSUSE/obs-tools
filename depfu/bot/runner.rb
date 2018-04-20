require 'octokit'
require './lib/depfu'
require 'yaml'

config = YAML.load_file('config/config.yml')
client = Octokit::Client.new(config[:credentials])
Depfu::PullRequestCommenter.new(client: client).run
