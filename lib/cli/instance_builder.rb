require 'yaml'

# EC2インスタンスを検索、生成するビルダー
class InstanceBuilder
  def initialize(host_profile = 'default',
                 repos = DiskMon::InstanceRepository.new)
    @repos = repos
    @host_profile = host_profile
  end

  def create_instances_from_file(filename: 'hosts.yml')
    config = YAML.safe_load(File.read(filename))
    hosts(config).map do |bastion, names|
      names.map { |name| @repos.create_proxied_instance(bastion, name) }
    end.flatten
  end

  private

  def hosts(config)
    if config.key? 'profile'
      haskey = config['profile'].key? @host_profile
      raise ArgumentError, "No such hosts #{@host_profile}" unless haskey
      config['profile'][@host_profile]
    else
      config['hosts']
    end
  end
end
