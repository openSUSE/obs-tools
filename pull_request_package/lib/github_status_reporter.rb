require 'active_model'
require 'open3'

class GitHubStatusReporter
  include ActiveModel::Model
  attr_accessor :client, :logger, :pull_request
  
  def report
    client.create_status('openSUSE/open-build-service', 'f73658fa927b90a0a3d28b79866215210b856390', 'pending', options) if [:success, :failed].include?(state)
  end
  
  def options
    options = { 
      context: 'OBS Package build result', 
      target_url: package.url,
    }
  end
  
  def state
    result = `osc api /status/project/#{package.obs_project_name}`
    # TODO: Parse result to get the state
    nil
  end
end
