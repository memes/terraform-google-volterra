#  frozen_string_literal: true

ruby '3.3.6'

source 'https://rubygems.org'
gem 'inspec-core', '~> 6.8.11'
# Nori 2.7 causes problems with inspec-gcp, so pin to 2.6
# See https://github.com/inspec/inspec-gcp/issues/596
gem 'nori', '~> 2.6.0'
group :dev do
  gem 'inspec-core-bin', '~> 6.8.11', require: false
  gem 'reek', '~> 6.4.0', require: false
  # gem 'rubocop', '~>1.71.0', require: false
end
