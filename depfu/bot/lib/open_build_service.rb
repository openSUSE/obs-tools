require 'active_model'
require 'nokogiri'

module OpenBuildService
  class Package
    include ActiveModel::Model
    attr_accessor :project_name, :name, :version
    
    def self.all(project)
      result = `osc -c /home/bot/config/.oscrc api /status/project/#{project}`
      Nokogiri::XML(result).xpath("//package").map do |package|
        new(
          name: package.attribute('name').value.strip,
          project_name: package.attribute('project').value.strip,
          version: package.attribute('version').value.strip
        )
      end
    end
    
    def submit_requests
      search = "search/request?match=(state/@name='new')+and+(action/source/@project='#{project_name}')+and+(action/source/@package='#{name}')"
      result = `osc -c /home/bot/config/.oscrc api "#{search}"`
      Nokogiri::XML(result).xpath('//request').map do |request|
        SubmitRequest.new(request.attribute('id').value.strip)
      end
    end
  end
  SubmitRequest = Struct.new(:number)
end
