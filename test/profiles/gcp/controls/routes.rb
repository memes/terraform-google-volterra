# frozen_string_literal: true

control 'default-vpc-route' do
  title 'Ensure default VPC route matches expectations'
  impact 0.5
  vpcs = input('vpcs')
  project_id = input('project_id')

  vpcs.each_value do |v|
    describe google_compute_routes(project: project_id).where(network: v[:self_link],
                                                              dest_range: '0.0.0.0/0',
                                                              priority: 1000,
                                                              name: /default-route-\h{16}/) do
      its('count') { should eq 1 }
    end
    describe(google_compute_routes(project: project_id).where do
               network == v[:self_link] && name !~ /default-route-\h{16}/
             end) do
      its('count') { should eq 0 }
    end
  end
end
