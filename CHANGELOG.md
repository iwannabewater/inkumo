# Changelog

All notable changes to Inkumo are recorded here.

## Unreleased

- Refined project role labels with a warm engraved-paper tint that complements
  the ink-blue type and parchment canvas.
- Added source-level validation for icon mappings, local asset boundaries, and
  flow-layout guardrails.
- Hardened header link wrapping for long email, profile, and website labels.
- Fixed `make setup` on macOS Bash 3.2 by removing Bash 4 associative arrays
  from the font fetch script.
- Added bottom-center page markers and a last-page-only copyright footer.
- Reworked section and entry rows to support wrapping and pagination.
- Added a compact internship section and reusable `\Experience` row primitive.
- Expanded the icon registry with reproducible Devicon and Simple Icons fonts.
- Split icon font bindings and public mappings behind a stable import facade.
- Removed image-backed icon assets from the default build.
- Moved shell scripts into `scripts/`.
- Rewrote the sample resume for large language model and multimodal research.
- Added an Inkumo vector mark and a structured project presentation in the
  README.
- Pinned downloaded assets with SHA-256 validation and hardened clean-build
  PDF verification.
- Added PDF validation, pinned CI actions, dependency updates, contribution
  guidance, and license/font notices.

## 0.1.0 - 2026-05-05

- Introduced the Inkumo XeLaTeX resume class.
- Added modular content sections, platform icon registry, local font fetching,
  and GitHub Actions PDF build validation.
