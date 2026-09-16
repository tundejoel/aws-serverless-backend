# Serverless backend for adedayoafolabi.com

Powers the visitor counter and contact form on my portfolio site.
AWS Lambda + API Gateway + DynamoDB + SES, all managed with Terraform.

**Live:** https://adedayoafolabi.com · **Front end:** [aws-portfolio-site](https://github.com/tundejoel/aws-portfolio-site)

## How it works

- `GET /visits` → Lambda does an atomic `ADD 1` on a DynamoDB item and returns the count; the page writes it into the footer.
- `POST /contact` → Lambda validates `{name, email, message}`, then sends it via SES to my inbox with the visitor as Reply-To.

The browser talks only to API Gateway. Lambda and DynamoDB have no public endpoint.

## Security

- One least-privilege IAM role per function: `dynamodb:UpdateItem` on one table, or `ses:SendEmail` from one verified domain. Nothing else.
- Only this API may invoke the functions (permission scoped to its execution ARN).
- Contact input validated in Lambda (required fields, size limits) before SES is ever called; returns `400` otherwise.
- CORS restricted to the site's origin. No stored credentials; state is local and git-ignored.

## Stack

Terraform manages everything: table, roles, functions (zipped from `lambda/` via the `archive` provider), 14-day log groups, HTTP API with routes and stage, SES domain identity with DKIM records in Route 53.

## Cost

$0 idle. Lambda free tier covers 1M runs/month; DynamoDB, API Gateway and SES are fractions of a cent per thousand requests.

## Deploy

```bash
terraform init && terraform apply
curl https://<api-url>/visits
```