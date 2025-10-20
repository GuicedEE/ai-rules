# CI/CD Implementation

* GitHub Actions for test/build/scan/deploy.
* Branch-based deployments: `dev`, `qe`, `main`.
* Maven release plugin manages versioning.
* SonarQube properties split by module and aggregated.
* GitHub Pages regenerated on release tag.
* All modules must provide `README.md` and render diagrams in final output.