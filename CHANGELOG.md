# Changelog

All notable changes to Inkumo are recorded here.

## Unreleased

## 0.3.1 - 2026-06-15

- Unified Font Awesome, Devicon, Simple Icons, and text-badge glyphs behind one
  aspect-ratio-preserving icon component with shape-aware visual bounds,
  stable minimum spacing, and consistent baseline alignment.
- Routed class chrome through named icon keys and added optional per-use color
  while preserving the existing `\PIcon` and `\definePIcon` interfaces.
- Preserved the natural width of profile metadata glyphs while keeping X and
  Zhihu compact, with geometry checks that cover visible shapes and reject
  production glyphs that bypass the shared component.

## 0.3.0 - 2026-06-15

- Reworked the header into independent contact/social and profile metadata
  groups with automatic separators that disappear at wrapped line edges.
- Added LinkedIn, X, and Zhihu profile examples plus an algorithm-engineer
  profession item, backed by native brand and role icon mappings.
- Added regression checks for wrapped contact separators and clickable PDF
  annotations.
- Kept release-asset compilation isolated so `make release-assets` writes only
  the two final PDFs to `dist/`.

## 0.2.1 - 2026-06-13

- Refactored header composition and validation tooling into focused,
  single-purpose helpers and explicit PDF fixtures.
- Added local release tooling that builds, uploads, and checksum-verifies both
  text-only and avatar PDF assets without tracking the personal avatar file.
- Expanded avatar guidance and validation for PDF, PNG, JPG, and JPEG inputs,
  including non-positive size fallback coverage.

## 0.2.0 - 2026-06-13

- Added an optional `\inkumoavatar` header photo interface with PDF validation
  coverage and local privacy defaults.
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
