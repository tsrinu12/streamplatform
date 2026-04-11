# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

The StreamPlatform team takes security seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please email us directly at:
- **Email**: security@streamplatform.com
- **PGP Key**: (to be added)

### What to Include

When reporting a vulnerability, please include:
- Description of the vulnerability
- Steps to reproduce
- Impact assessment
- Suggested fix (if any)
- Your contact information

### What to Expect

1. **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
2. **Assessment**: We will evaluate the severity and impact within 5 business days
3. **Resolution**: We aim to resolve critical vulnerabilities within 7 days
4. **Disclosure**: Coordinated disclosure after the fix is deployed

### Security Measures in Place

- OIDC-based AWS credential management for CI/CD
- Istio service mesh with mTLS for service-to-service encryption
- AWS WAF for DDoS and web attack protection
- Network isolation between microservices
- Pod security standards enforcement
- Regular dependency scanning via Dependabot
- Branch protection and required PR reviews
- Encrypted S3 buckets and RDS instances

### Responsible Disclosure

We appreciate responsible disclosure and will credit researchers who report valid vulnerabilities (with your permission). We ask that you:
- Give us reasonable time to address the issue before public disclosure
- Do not exploit the vulnerability beyond what is necessary to demonstrate it
- Do not access, modify, or delete data
- Do not disrupt service availability

Thank you for helping keep StreamPlatform secure.
