# Add a delay during tofu/terraform apply and destroy phases

When debugging test failures it can be useful to delay the tear down of resources, or to introduce a delay between
dependent steps.

## Example

To provide 10 minutes of delay before tearing down a successful test, add a `delete_duration` run at the end of the test
file.

```hcl
...

run "pause" {
  command = apply

  module {
    source = "./tests/modules/pause/"
  }

  variables {
    delete_duration = "600s"
  }
}
```

To provide 30 seconds of delay between run steps, add a `create_duration` run between them
file.

```hcl

run "dependency" {
    ...
}

run "pause" {
  command = apply

  module {
    source = "./tests/modules/pause/"
  }

  variables {
    create_duration = "30s"
  }
}

run "next" {
    ...
}
```

<!-- markdownlint-disable MD033 MD034-->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.alpha](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.omega](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.pause](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_duration"></a> [create\_duration](#input\_create\_duration) | The duration to pause during resource creation phase. The default value will<br/>not generate a pause during creation; a value must be provided to force a<br/>delay. Format should be a positive integer followed by one of h, m, s, or<br/>ms. | `string` | `null` | no |
| <a name="input_destroy_duration"></a> [destroy\_duration](#input\_destroy\_duration) | The duration to pause during resource destruction phase. The default value<br/>will not generate a pause during creation; a value must be provided to force<br/>a delay. Format should be a positive integer followed by one of h, m, s, or<br/>ms. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
<!-- markdownlint-enable MD033 MD034 -->
