# CI/CD — Topic Index

Purpose
- Use this topic for continuous integration and delivery pipelines, infrastructure-as-code automation, and deployment workflows.
- Providers below are selectable from starter prompts; choose those used in the host environment and link provider docs from project RULES/GUIDES.

Providers (selection supported in prompts)
- GitHub Actions — ./providers/github-actions.md
- GitLab CI — ./providers/gitlab-ci.md
- Jenkins — ./providers/jenkins.md
- TeamCity — ./providers/teamcity.md
- Google Cloud Build — ./providers/google-cloud-build.md
- Azure Pipelines — ./providers/azure-pipelines.md
- AWS CodeBuild/CodePipeline — ./providers/aws-codebuild-codepipeline.md

Guides
- Terraform examples — ./terraform/ (browse)
- General CI/CD patterns (matrix builds, caching, artifacts, approvals, environments) — coming soon

Prompt integration
- New/Adopt/Library/Health Check prompts offer “CI/CD” selections that include all providers listed above.
- Projects should:
  - Declare chosen provider(s) in RULES.md
  - Add minimal pipeline(s) for build/test and deploy stages
  - Reference environment variables and secrets per provider securely

See also
- Platform category index — ../README.md
- RULES.md — Generative Topic Taxonomy; Document Modularity Policy
