# OCP 4 UPI on vSphere

Quick method to deploy OCP 4.x UPI on vSphere using terraform for initializing cluster members and ISOs for booting

## Usage

  1. Rename `vars.tf.sample` to `vars.tf`
  2. Update connection and deployment variables in `vars.tf`
  3. Execute `terraform init` to download the appropriate provider(s)
  4. Execute `terraform apply`

