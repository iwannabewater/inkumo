#!/usr/bin/env python3
"""Structured source and PDF validators for Inkumo."""

import argparse
import collections
import fnmatch
import re
import subprocess
from pathlib import Path


ICON_DEFINITION_PATTERN = re.compile(r"^\\definePIcon\{([^{}]+)\}", re.MULTILINE)
ICON_USAGE_PATTERN = re.compile(
    r"\\(?:Tech|ContactItem|ContactHref|PIcon)\{([^{}]+)\}"
)
CONTACT_URL_PATTERN = re.compile(
    r"\\ContactHref\{[^{}]+\}\{([^{}]+)\}\{"
)
FORBIDDEN_TRACKED_PATTERNS = (
    "*.pdf",
    "avatar.*",
    "content/avatar.*",
    "assets/avatar.*",
    "local/*",
    "fonts/*.ttf",
    "fonts/*.otf",
    "fonts/*.woff",
    "fonts/*.woff2",
    "assets/devicon/devicon.ttf",
    "assets/devicon/LICENSE",
    "assets/simple-icons/SimpleIcons.ttf",
    "assets/simple-icons/simple-icons.json",
    "assets/simple-icons/LICENSE.md",
    "assets/simple-icons/DISCLAIMER.md",
)


def fail(message):
    raise SystemExit(f"FAIL: {message}")


def read_text(path):
    return path.read_text(encoding="utf-8")


def registry_keys(registry_path):
    keys = ICON_DEFINITION_PATTERN.findall(read_text(registry_path))
    duplicates = sorted(
        key for key, count in collections.Counter(keys).items() if count > 1
    )
    if duplicates:
        fail("duplicate icon registry keys: " + ", ".join(duplicates))
    if not keys:
        fail("icon registry is empty")
    return keys


def tracked_files(root):
    probe = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--is-inside-work-tree"],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if probe.returncode != 0:
        return []
    output = subprocess.check_output(
        ["git", "-C", str(root), "ls-files"],
        text=True,
        encoding="utf-8",
    )
    return output.splitlines()


def validate_source(root):
    registry = root / "lib" / "icon-registry.tex"
    definitions = set(registry_keys(registry))

    sources = [root / "resume.tex", *sorted((root / "content").glob("*.tex"))]
    content = "\n".join(read_text(path) for path in sources)
    missing = sorted(set(ICON_USAGE_PATTERN.findall(content)) - definitions)
    if missing:
        fail("missing icon mappings for content keys: " + ", ".join(missing))

    forbidden = [
        path
        for path in tracked_files(root)
        if any(
            fnmatch.fnmatch(path, pattern)
            for pattern in FORBIDDEN_TRACKED_PATTERNS
        )
    ]
    if forbidden:
        fail(
            "tracked generated, third-party, or personal local assets: "
            + ", ".join(forbidden)
        )


def validate_footer(header_path, page_text_path):
    header = read_text(header_path)
    page_text = read_text(page_text_path)

    match = re.search(r"\\inkumoheader\s*\{([^{}]+)\}", header, re.DOTALL)
    if not match:
        fail("could not read name from content/header.tex")

    name = re.sub(r"%.*", "", match.group(1))
    name = name.replace("~", " ")
    name = re.sub(r"\\[ ,;:!]+", " ", name)
    name = re.sub(r"\s+", " ", name).strip()

    normalized_page = re.sub(r"\s+", " ", page_text)
    if name not in normalized_page:
        fail(f"missing header name in last-page signature: {name}")


def validate_contact_flow(page_text_path):
    lines = [
        line.rstrip()
        for line in read_text(page_text_path).splitlines()
        if line.strip()
    ]
    first_group = (
        "AlphaPhone",
        "BravoEmail",
        "CharlieGitHub",
        "DeltaTelegram",
        "EchoWebsite",
        "FoxtrotLinkedIn",
        "GolfX",
        "HotelZhihu",
    )
    second_group = (
        "IndiaUniversity",
        "JulietComputerScience",
        "KiloAlgorithmEngineer",
        "LimaBeijing",
        "MikeMultimodalResearch",
        "NovemberResearchLab",
    )

    def item_line(item):
        matches = [index for index, line in enumerate(lines) if item in line]
        if len(matches) != 1:
            fail(f"contact flow item must appear exactly once: {item}")
        return matches[0]

    first_lines = {item_line(item) for item in first_group}
    second_lines = {item_line(item) for item in second_group}

    if len(first_lines) < 2 or len(second_lines) < 2:
        fail("contact flow fixture did not wrap both semantic groups")
    if first_lines & second_lines:
        fail("contact flow groups rendered on the same visual line")
    if max(first_lines) >= min(second_lines):
        fail("contact flow groups rendered out of order")
    if not any("•" in line for line in lines):
        fail("contact flow fixture contains no visible inline separators")
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("•") or stripped.endswith("•"):
            fail(f"contact separator leaked to a wrapped edge: {stripped}")


def validate_header_links(header_path, url_report_path):
    expected = set(CONTACT_URL_PATTERN.findall(read_text(header_path)))
    actual = set()
    for line in read_text(url_report_path).splitlines():
        columns = line.split(maxsplit=2)
        if len(columns) == 3 and columns[0].isdigit():
            actual.add(columns[2])
    missing = sorted(expected - actual)
    if missing:
        fail("missing PDF contact links: " + ", ".join(missing))


def write_icon_audit(registry_path, output_path):
    keys = registry_keys(registry_path)
    lines = [
        r"\documentclass{inkumo}",
        r"\input{lib/icons.tex}",
        r"\begin{document}",
    ]
    lines.extend(r"\setbox0=\hbox{\PIcon{%s}}" % key for key in keys)
    lines.extend(["icon registry audit", r"\end{document}"])
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def validate_release(root, tag):
    if not re.fullmatch(r"v[0-9]+\.[0-9]+\.[0-9]+", tag):
        fail(f"release tag must use vMAJOR.MINOR.PATCH: {tag}")

    version = tag[1:]
    class_text = read_text(root / "inkumo.cls")
    changelog = read_text(root / "CHANGELOG.md")

    class_match = re.search(
        r"\\ProvidesClass\{inkumo\}\[[0-9]{4}/[0-9]{2}/[0-9]{2} "
        r"v([^ ]+) ",
        class_text,
    )
    if not class_match:
        fail("could not read the class version from inkumo.cls")
    if class_match.group(1) != version:
        fail(
            f"class version {class_match.group(1)} does not match release {version}"
        )
    release_heading = (
        rf"^## {re.escape(version)} - "
        r"[0-9]{4}-[0-9]{2}-[0-9]{2}$"
    )
    if not re.search(release_heading, changelog, re.MULTILINE):
        fail(f"CHANGELOG.md has no dated {version} release section")


def build_parser():
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    source = subparsers.add_parser("source")
    source.add_argument("--root", type=Path, required=True)

    footer = subparsers.add_parser("footer")
    footer.add_argument("--header", type=Path, required=True)
    footer.add_argument("--page-text", type=Path, required=True)

    contact_flow = subparsers.add_parser("contact-flow")
    contact_flow.add_argument("--page-text", type=Path, required=True)

    links = subparsers.add_parser("links")
    links.add_argument("--header", type=Path, required=True)
    links.add_argument("--url-report", type=Path, required=True)

    icon_audit = subparsers.add_parser("icon-audit")
    icon_audit.add_argument("--registry", type=Path, required=True)
    icon_audit.add_argument("--output", type=Path, required=True)

    release = subparsers.add_parser("release")
    release.add_argument("--root", type=Path, required=True)
    release.add_argument("--tag", required=True)

    return parser


def main():
    args = build_parser().parse_args()
    if args.command == "source":
        validate_source(args.root.resolve())
    elif args.command == "footer":
        validate_footer(args.header, args.page_text)
    elif args.command == "contact-flow":
        validate_contact_flow(args.page_text)
    elif args.command == "links":
        validate_header_links(args.header, args.url_report)
    elif args.command == "icon-audit":
        write_icon_audit(args.registry, args.output)
    elif args.command == "release":
        validate_release(args.root.resolve(), args.tag)


if __name__ == "__main__":
    main()
