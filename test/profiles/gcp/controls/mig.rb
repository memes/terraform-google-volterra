# frozen_string_literal: true

require 'json'

# rubocop:disable Metrics/BlockLength
control 'instance-group-manager' do
  title 'Ensure instance group manager meets expectation'
  impact 0.5
  project_id = input('project_id')
  region = input('region')
  vpcs = input('vpcs')
  name = input('input_name')
  subnets = JSON.parse(input('output_subnets_json'), { symbolize_names: true })
  vm_options = JSON.parse(input('output_vm_options_json'), { symbolize_names: true })

  manager = google_compute_region_instance_group_manager(project: project_id, region:, name:)
  describe manager do
    it { should exist }
    its('target_size') { should eq 3 }
    its('base_instance_name') { should cmp name }
    its('instance_group') { should match(/#{name}$/) }
    its('instance_template') { should match(/#{name}-[0-9]+$/) }
  end

  describe google_compute_region_instance_group(project: project_id, region:,
                                                name: manager.instance_group.split('/')[-1]) do
    it { should exist }
    its('network') { should cmp vpcs[:outside][:self_link] }
  end

  template = google_compute_instance_template(project: project_id, name: manager.instance_template.split('/')[-1])
  describe template do
    it { should exist }
    its('properties.can_ip_forward') { should cmp true }
    its('properties.disks.first.initialize_params.disk_size_gb') { should cmp vm_options[:disk_size] }
    its('properties.machine_type') { should cmp vm_options[:instance_type] }
    its('properties.network_interfaces.count') { should eq 2 }
    its('properties.network_interfaces.first.network') { should cmp vpcs[:outside][:self_link] }
    its('properties.network_interfaces.first.subnetwork') { should cmp subnets[:outside] }
    its('properties.network_interfaces.last.network') { should cmp vpcs[:inside][:self_link] }
    its('properties.network_interfaces.last.subnetwork') { should cmp subnets[:inside] }
  end
  if vm_options[:ssh_key]
    metadata_ssh_keys = template.properties.metadata['items'].select do |item|
      item['key'] == 'ssh-keys'
    end
    first_metadata_ssh_key = metadata_ssh_keys.map { |entry| entry['value'] }.first
    describe first_metadata_ssh_key do
      it { should cmp "centos:#{vm_options[:ssh_key].strip}" }
    end
  end
end
# rubocop:enable Metrics/BlockLength
