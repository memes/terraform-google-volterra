# Changelog

<!-- spell-checker: ignore markdownlint volterra -->
<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.2] - 2021-09-30

### Added

### Changed

- Fixed Oregon DC longitude

### Removed

## [0.3.1] - 2021-07-28

### Added

### Changed

- Updated Google and Volterra provider versions
- Updated Google IAM and SA modules

### Removed

## [0.3.0] - 2021-07-21

### Added

- `region-locations` module to provide a map of known GCP regions to approximate
  latitude and longitude.

### Changed

### Removed

## [0.2.1] - 2021-04-01

### Added

### Changed

- Fixed role name validation bug

### Removed

## [0.2.0] - 2021-04-01

### Added

- Service account module to create a GCP service account, with binding to custom
  IAM role, with credentials stored in Volterra tenant as a GCP Cloud Credential.

### Changed

### Removed

## [0.1.0] - 2021-04-01

### Added

- Custom IAM role for VPC Site management (originally from https://github.com/memes/volterra-lab/tree/main/modules/volterra_vpc_role)

### Changed

### Removed

[0.3.2]: https://github.com/memes/terraform-google-volterra/compare/0.3.1...0.3.2
[0.3.1]: https://github.com/memes/terraform-google-volterra/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/memes/terraform-google-volterra/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/memes/terraform-google-volterra/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/memes/terraform-google-volterra/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/memes/terraform-google-volterra/releases/tag/0.1.0
