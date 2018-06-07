require 'octokit'
require 'active_model'
require './lib/open_build_service'
require './lib/sawyer'

module Depfu
  class PullRequestBodyParser
    include ActiveModel::Model
    attr_accessor :body

    def parse
      result = []
      body.each_line do |line|
        next unless table_line?(line)
        splitted = line.split('|')
        if ['updated', 'created', 'added'].include?(splitted[1].strip)
          result << Gem.new(splitted[2].strip, splitted[4].strip)
        end
      end
      result
    end
    
    def table_line?(line)
      line.start_with?('|') && !line.start_with?('| name') && !line.start_with?('| action') && !line.start_with?('| ---')
    end
  end
  
  class PullRequest
    include ActiveModel::Model 
    attr_accessor :number, :dependencies
    
    def self.all(client = Octokit)
      client.pull_requests('openSUSE/open-build-service').select { |pr| pr.depfu? }.map do |pr|
        dependencies = PullRequestBodyParser.new(body: pr.body).parse
        new(number: pr.number, dependencies: dependencies)
      end
    end
  end

  Gem = Struct.new(:name, :version)
  
  class PullRequestCommenter
    include ActiveModel::Model
    attr_accessor :client
    
    def run
      depfu_pull_requests.each do |pull_request|
        body = build_comment(pull_request)
        bot_comment = bot_comment(pull_request.number)
        if bot_comment
          update_comment(body, bot_comment)
        else
          create_comment(body, pull_request)
        end
      end
    end
    
    private
    
    def depfu_pull_requests
      @depfu_pull_requests ||= Depfu::PullRequest.all(client)
    end
    
    def obs_packages
      @obs_packages ||= OpenBuildService::Package.all('OBS:Server:Unstable')
    end
    
    def devel_ruby_packages
      @devel_ruby_packages ||= OpenBuildService::Package.all('devel:languages:ruby:extensions')
    end
    
    def factory_auto_packages
      @factory_auto_packages ||= OpenBuildService::Package.all('home:factory-auto:branches:devel:languages:ruby:extensions')
    end
    
    def build_comment(pull_request)
      msg = "Result for PR##{pull_request.number}\n"
      pull_request.dependencies.each do |gem|
        if obs_packages.any? { |package| package.name.end_with?(gem.name) && package.version == gem.version }
          msg << "- Package #{gem.name} is already up to date in O:S:U (#{gem.version}).\n"
        elsif devel_ruby_packages.any? { |package| package.name.end_with?(gem.name) && package.version == gem.version }
          msg << "- Package #{gem.name} is already up to date in d:l:r:e (#{gem.version}), update link reference with `osc setlinkrev OBS:Server:Unstable rubygem-#{gem.name}`.\n"
        elsif factory_auto_packages.any? { |package| package.name.end_with?(gem.name) && package.version == gem.version }
          submit_request = factory_auto_packages.find { |package| package.name.end_with?(gem.name) && package.version == gem.version }.submit_requests.first
          if submit_request
            msg << "- There is already a submit request for package #{gem.name} (#{gem.version}). "
            msg << "Please review and accept [#{submit_request.number}](https://build.opensuse.org/request/show/#{submit_request.number}).\n"
          else
            msg << "- There is already a package in https://build.opensuse.org/project/show/home:factory-auto:branches:devel:languages:ruby:extensions project but no submit request. "
            msg << "Most likely something with the factory-auto bot went wrong, try to branch the project to your home and submit it manually.\n"
          end
        else
          msg << "- There is no submit request for #{gem.name} (#{gem.version}).\n"
          msg << "- If you recently accepted a submit request, the repository is probably not yet published!\n"
        end
      end
      msg
    end
    
    def update_comment(body, comment)
      puts "Comment ##{comment.id} already exists"
      return if comment.body == body
      puts "Comment ##{comment.id} did change, updating..."
      client.update_comment('openSUSE/open-build-service', comment.id, body)
    end
    
    def create_comment(body, pull_request)
      puts "No comment, creating new one..."
      client.add_comment('openSUSE/open-build-service', pull_request.number, body)
    end
    
    def bot_comment(pull_request_number)
      client.issue_comments('openSUSE/open-build-service', pull_request_number).find { |comment| comment.user.login == client.user.login }
    end
  end
end
