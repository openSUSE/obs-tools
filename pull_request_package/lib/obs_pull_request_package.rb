require 'active_model'
require 'nokogiri'
require 'tempfile'
require 'fileutils'
require 'open3'

class ObsPullRequestPackage
  include ActiveModel::Model
  attr_accessor :pull_request, :logger, :template_directory
  PullRequest = Struct.new(:number)
  
  def self.all(logger)
    result = `osc api "search/project?match=starts-with(@name,'OBS:Server:Unstable:TestGithub:PR')"`
    xml = Nokogiri::XML(result)
    xml.xpath('//project').map do |project|
      pull_request_number = project.attribute('name').to_s.split('-').last.to_i
      ObsPullRequestPackage.new(pull_request: PullRequest.new(pull_request_number), logger: logger)
    end
  end

  def delete
    capture2e_with_logs("osc api -X DELETE source/#{obs_project_name}")
  end

  def ==(other)
    pull_request.number == other.pull_request.number
  end

  def eql?(other)
    pull_request.number.eql(other.pull_request.number)
  end

  def hash
    pull_request.number.hash
  end

  def pull_request_number
    pull_request.number
  end
  
  def commit_sha
    pull_request.head.sha
  end
  
  def obs_project_name
    "OBS:Server:Unstable:TestGithub:PR-#{pull_request_number}"
  end
  
  def url
    "https://build.opensuse.org/package/show/#{obs_project_name}/obs-server"
  end
  
  def last_commited_sha
    history = `osc api "/source/#{obs_project_name}/obs-server/_history"`
    node = Nokogiri::XML(history).root
    return '' unless node
    node.xpath('.//revision/comment').last.content
  end

  def create
    return if last_commited_sha == commit_sha
    create_project
    create_package
    copy_files
  end
  
  private
  
  def capture2e_with_logs(cmd)
    logger.info("Execute command '#{cmd}'.")
    stdout_and_stderr_str, status = Open3.capture2e(cmd)
    stdout_and_stderr_str.chomp!
    if status.success?
      logger.info(stdout_and_stderr_str)
    else
      logger.error(stdout_and_stderr_str)
    end
    stdout_and_stderr_str
  end
  
  def create_project
    Tempfile.open("#{pull_request_number}-meta") do |f|
      f.write(project_meta)
      f.close
      capture2e_with_logs("osc meta prj #{obs_project_name} --file #{f.path}")
    end
  end
  
  def project_meta
    file = File.read('new_project_template.xml')
    xml = Nokogiri::XML(file)
    xml.root['name'] = obs_project_name
    xml.css('title').first.content = "https://github.com/openSUSE/open-build-service/pull/#{pull_request_number}"
    xml.to_s
  end
  
  def create_package
    capture2e_with_logs("osc meta pkg #{obs_project_name} obs-server --file new_package_template.xml")
  end
  
  def copy_files
    Dir.mktmpdir do |dir|
      capture2e_with_logs("osc co OBS:Server:Unstable/obs-server --output-dir #{dir}/template")
      capture2e_with_logs("osc co #{obs_project_name}/obs-server --output-dir #{dir}/#{obs_project_name}")
      copy_package_files(dir)
      capture2e_with_logs("osc ar #{dir}/#{obs_project_name}")
      capture2e_with_logs("osc commit #{dir}/#{obs_project_name} -m '#{commit_sha}'")
    end
  end
  
  def copy_package_files(dir)
    Dir.entries("#{dir}/template").reject { |name| name.start_with?('.') }.each do |file|
      path = File.join(dir, 'template', file)
      target_path = File.join(dir, obs_project_name, file)
      if file == '_service'
        copy_service_file(path, target_path)
      else
        FileUtils.cp path, target_path
      end
    end
  end
    
  def copy_service_file(path, target_path)
    File.open(target_path, 'w') do |f|
      f.write(service_file(path))
    end
  end
  
  def service_file(path)
    content = File.read(path)
    xml = Nokogiri::XML(content)
    node = xml.root.at_xpath(".//param[@name='revision']")
    node.content = commit_sha
    xml.to_s
  end
end
