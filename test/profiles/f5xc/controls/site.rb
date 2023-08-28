# frozen_string_literal: true

control 'site' do
  title 'Ensure F5XC GCP VPC site meets expectation'
  impact 0.5
  name = input('input_name')
  description = input('input_description', value: 'GCP VPC Site')

  describe volterra_site(name: name) do
    it { should exist }
    its('metadata.description') { should cmp description }
    its('address') { should be_nil.or be_empty }
    its('bgp_peer_address') { should be_nil.or be_empty }
    its('bgp_router_id') { should be_nil.or be_empty}
    its('ce_site_mode') { should cmp 'CE_SITE_MODE_INGRESS_EGRESS_GW' }
    its('connected_re.count') { should eq 2 }
    its('connected_re_for_config.count') { should be >= 1 }
    its('coordinates.latitude') { should_not be_nil }
    its('coordinates.longitude') { should_not be_nil }
  end
end
