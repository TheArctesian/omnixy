# Releasing

Every push to `master` runs [`.github/workflows/release.yml`](../.github/workflows/release.yml). Merging a PR is a push to `master`, so each merged PR makes one release. The version comes from N, the number of PRs merged into `master`. The patch and minor numbers each hold two digits: `v<N / 10000>.<N / 100 mod 100>.<N mod 100>`. So PR 4 is `v0.0.4`, PR 100 is `v0.1.0`, PR 10,000 is `v1.0.0`, and PR 3,222,222 is `v322.22.22`. If no new PR was merged, the tag already exists and the run does nothing.

The workflow:

1. Builds `.#iso` on a GitHub runner, after freeing disk space. This takes about 1 to 2 hours.
2. Uploads the ISO and `SHA256SUMS` to the `omnixy-iso` R2 bucket under `releases/<version>/`. It then copies them to `latest/`, which has a stable URL.
3. Deletes all but the newest 3 releases from the bucket.
4. Tags the commit and creates the GitHub release. The release links to the ISO and has `SHA256SUMS` attached. The ISO itself is not attached: it is about 4.5 GB, and GitHub limits assets to 2 GiB. The tag is created last, so a failed build does not use up a version: the next push to `master` retries it.

The bucket is served at `https://iso.omnixy.org` (an R2 custom domain on the `omnixy.org` zone).

To rebuild an existing version, run the workflow by hand (Actions › Release › Run workflow) with its tag, for example `v0.0.5`. If several PRs are merged while a build is running, the next run releases the newest commit under the newest count. Version numbers can skip, because one release can cover several PRs.

## One-time setup

- **R2:** enable R2 on the Cloudflare account. Create the `omnixy-iso` bucket and connect the custom domain `iso.omnixy.org` to it.
- **API token:** create an R2 API token with *Object Read & Write* on `omnixy-iso` only.
- **GitHub:** set these on the repository:

  ```bash
  gh secret set R2_ACCESS_KEY_ID
  gh secret set R2_SECRET_ACCESS_KEY
  gh variable set R2_ACCOUNT_ID --body <cloudflare account id>
  ```
