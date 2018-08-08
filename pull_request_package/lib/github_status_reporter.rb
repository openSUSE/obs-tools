require 'active_model'
require 'open3'
require 'nokogiri'

class GitHubStatusReporter
  include ActiveModel::Model
  attr_accessor :client, :logger, :pull_request

  def report
    return unless [:success, :error].include?(state)
    client.create_status('openSUSE/open-build-service', 'f73658fa927b90a0a3d28b79866215210b856390', state, options) 
  end

  private

  def options
    options = { 
      context: 'OBS Package build result', 
      target_url: package.url,
    }
  end

  def state
    return :success if states.all? { |i| i == 'succeeded' }
    return :error if states.include?('failed')
    # do only send status for success or error
    nil
  end

  def states
    return @states if @states
    @states = []
    states_xml.xpath('//result/status').each do |element|
      @states << element.attribute('code').to_s
    end
    @states
  end

  def states_xml
    result = `osc api 'build/#{package.obs_project_name}/_result?package=obs-server&multibuild=1&locallink=1'`
    Nokogiri::XML(result)
  end
end
