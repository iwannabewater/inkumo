# Assets

`brand/inkumo-mark.svg` is Inkumo's first-party vector mark and is tracked
under the repository's MIT License.

Inkumo keeps downloaded third-party icon fonts out of Git. Run:

```bash
make setup
```

This downloads the local assets required for a complete render and checks their
SHA-256 digests. Downloaded files are ignored by `.gitignore`; first-party
branding, source notes, and fetch scripts are tracked.
