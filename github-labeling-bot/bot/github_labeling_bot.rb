require 'octokit'

class GithubLabelingBot

  attr_accessor :config
  attr_accessor :client
  attr_accessor :repository

  def initialize(configuration)
    @config = configuration
    Octokit.auto_paginate = true
    @client = Octokit::Client.new(@config[:credentials])
    @repository = @client.repo(repository_name)
  end

  def repository_name
    "#{@config[:owner]}/#{@config[:repository]}"
  end

  def pull_requests
    @repository.rels[:pulls].get.data
  end

  def commits(pull_request)
    pull_request.rels[:commits].get.data
  end

  def files(pull_request)
    @client.pull_request_files(repository_name, pull_request.number)
  end

  def tags_in_commits(commits)
    tags = []
    commits.each do |commit|
      matches = commit[:commit][:message].scan(/\[\w+\]/)
      matches.each do |tag|
        tags << tag.gsub(/[\[\]]/,'')
      end
    end
    tags.uniq
  end

  def labels_by_commits(commits)
    labels = []
    tags_in_commits(commits).each do |tag|
      labels << @config[:labels_by_commit][tag]
    end
    labels.uniq
  end

  def tag_by_file(file)
    label = nil
    @config[:labels_for_files].keys.find do |dir|
      match = file.match(/^#{dir}/)
      label = @config[:labels_for_files][match.to_s]
    end
    label
  end

  def labels_by_files(files)
    labels = []
    files.map(&:filename).each do |filename|
      labels << tag_by_file(filename)
    end
    labels.uniq
  end

  def labels(pull_request)
    @client.labels_for_issue(repository_name, pull_request.number).map(&:name)
  end

  def update_labels(pull_request, labels)
    @client.add_labels_to_an_issue(repository_name, pull_request.number, labels)
  end

  def update_labels_for_pull_request(pull_request)
    actual_labels = labels(pull_request)
    commits = commits(pull_request)
    files = files(pull_request)
    labels = labels_by_commits(commits)
    labels += labels_by_files(files)
    labels = labels.flatten.compact.uniq.sort
    puts "\nPR ##{pull_request.number} #{pull_request.title} [#{commits.size} commit/s and #{files.size} file/s]"
    puts "   >  Actual labels:     #{actual_labels}"
    puts "   >  Calculated labels: #{labels}"
    labels -= actual_labels
    unless labels.empty?
      puts "   <--  Adding labels:   #{labels}"
      update_labels(pull_request, labels)
    end
  end

  def run
    puts "Github Labeling Bot"
    puts "Adding labels to the PRs on Github repository '#{repository_name}'"
    pull_requests.each do |pull_request|
      update_labels_for_pull_request(pull_request)
    end
  end
end
