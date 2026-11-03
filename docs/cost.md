# Cost

I am working with a small personal budget, so cost shaped most of the design. Prices are approximate us-east-1
on-demand figures; check Infracost or the pricing calculator before relying on them.

## Before the first apply

1. Create an AWS Budget with email alerts.
2. Destroy when you are done: `terraform destroy` in the environment you applied.
3. After destroying, check for leftovers: EC2 instances, RDS instances and snapshots, NAT gateways, Elastic IPs,
   load balancers and EBS volumes.

## Profiles

| | dev | prod |
|---|---|---|
| EC2 | 1 x t3.micro | 2 x t3.micro (min 2, max 3) |
| Load balancer | none | ALB |
| Database | local Postgres on the instance | RDS db.t4g.micro, single-AZ |
| NAT gateway | none | none (see [architecture.md](architecture.md)) |
| Rough hourly cost | $0.02 | $0.11 |
| Left running all month | about $11 | roughly $80 |

The prod figure is the one I measured while it was up; the monthly numbers are just that rate times 730 hours, so
treat them as ballpark. I run prod for an hour or two to test and take screenshots, then destroy it.

## Left out on purpose

WAF, a NAT gateway per AZ, customer-managed KMS keys, enhanced RDS monitoring, GuardDuty and Config. They would
all be reasonable on a real workload.
