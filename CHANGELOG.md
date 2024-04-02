# Changelog

<!-- spell-checker: ignore markdownlint volterra -->
<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0](https://github.com/memes/terraform-google-volterra/compare/v0.3.2...v0.4.0) (2024-04-02)


### Features

* Remove obsolete region-location submodule ([39be513](https://github.com/memes/terraform-google-volterra/commit/39be513bee3475bc78d7810b1da4e5168366240d))
* Remove obsolete role submodule ([5e27d90](https://github.com/memes/terraform-google-volterra/commit/5e27d909c14b18bd540651f9fee03f3109fc69ab))


### Bug Fixes

* Don't add labels/annotations ([4958ca5](https://github.com/memes/terraform-google-volterra/commit/4958ca504cb488a6046b5faf76a0e053a7cd1472)), closes [#36](https://github.com/memes/terraform-google-volterra/issues/36)

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
