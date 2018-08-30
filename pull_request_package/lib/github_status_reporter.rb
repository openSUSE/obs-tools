require 'active_model'
require 'open3'

class GitHubStatusReporter
  include ActiveModel::Model
  attr_accessor :client, :logger, :package
  
  def report
    client.create_status('openSUSE/open-build-service', package.commit_sha, state, options)
  end

  private

  def description
    count_all = summary[:success] + summary[:failure] + summary[:pending]
    count_finished = count_all - summary[:pending]

    result = "#{count_finished}/#{count_all} processed"
    result << " | #{summary[:failure]} failures" if summary[:failure] > 0

    result
  end

  def state
    state = :success
    if summary[:failure] > 0
      state = :failure
    elsif summary[:pending] > 0 or summary[:success] == 0
      state = :pending
    end
    state
  end

  def options
    options = { 
      context: "OBS Package Build",
      target_url: package.url,
      description: description
    }
  end
  
  def judge_code(code)
    case code
    when 'succeeded', 'excluded', 'disabled'
      :success
    when 'broken', 'failed', 'unresolvable'
      :failure
    when 'building', 'dispatching', 'scheduled', 'finished', 'blocked'
      :pending
    else
      logger.error("Unmapped status result #{code} in #{package.obs_package_name}")
      :pending
    end
  end

  def summary
    return @summary if @summary
    @summary = { failure: 0, success: 0, pending: 0 }
    result = `osc api /build/#{package.obs_project_name}/_result`
    node = Nokogiri::XML(result).root
    node.xpath('.//status').each do |status|
      @summary[judge_code(status['code'])] += 1
    end
    @summary
  end
end
