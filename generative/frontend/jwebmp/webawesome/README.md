# WebAwesome (JWebMP Wrapper) — Topic Index

Use this topic when generating or maintaining the WebAwesome JWebMP wrapper that consumes Angular Awesome components. Apply it alongside the base WebAwesome component rules and the JWebMP client/Angular topics; treat generated TS/HTML as read-only.

Scope and policy
- Forward-only, documentation-first (stage gates auto-approved per PROMPT_LIBRARY_RULES_UPDATE.md); update indexes instead of keeping legacy anchors.
- CRTP fluent setters only (no builders); Log4j2 logging; JSpecify nullness defaults.
- Asset loading goes through `WebAwesomePageConfigurator`: CSS with `RequirementsPriority.First`, JS module with `Top_Shelf` priority, theme/body classes applied when present.
- Avoid inline HTML; build markup from JWebMP components. Generated TypeScript artifacts stay untouched.

How to use this index
- Start with Overview, then wire assets via the page configurator rules before adding components.
- Use component rules here for wrapper-specific guidance (attributes, slots, CRTP chaining) and defer behavioral details to the base WebAwesome rules under `../../webawesome/`.
- Keep prompt language alignment (WaButton, WaInput, WaCluster, WaStack) and copy only enforced names into host glossaries; link back to `./GLOSSARY.md` for everything else.
- Diagram references live in `docs/architecture/README.md` (context/container/component/sequences/ERD) for this plugin.

Topics
- Overview and scope — ./overview.rules.md
- Page configurator and assets — ./page-configurator.rules.md
- Layout primitives:
  - WaCluster (row layout; attach grid utilities here, not on stacks) — ./cluster.rules.md
  - WaStack (column layout; plain list, no grid semantics) — ./stack.rules.md
  - WaGrid — ./grid.rules.md
  - WaFrame — ./frame.rules.md
  - WaFlank — ./flank.rules.md
  - WaSplit — ./split.rules.md
- Components:
  - WaAnimatedImage — ./animated-image.rules.md
  - WaAnimation — ./animation.rules.md
  - WaAvatar / WaAvatarGroup — ./avatar.rules.md
  - WaBadge — ./badge.rules.md
  - WaBreadcrumbs / WaBreadcrumbItem — ./breadcrumbs.rules.md
  - WaButton — ./button.rules.md
  - WaCallout — ./callout.rules.md
  - WaCard — ./card.rules.md
  - WaCarousel / WaCarouselItem — ./carousel.rules.md
  - WaCheckbox — ./checkbox.rules.md
  - WaColorPicker — ./color-picker.rules.md
  - WaComparison / WaImageCompare — ./comparison.rules.md and ./image-compare.rules.md
  - WaCopyButton — ./copy-button.rules.md
  - WaDetails — ./details.rules.md
  - WaDialog — ./dialog.rules.md
  - WaDivider — ./divider.rules.md
  - WaDrawer — ./drawer.rules.md
  - WaFormatBytes — ./format-bytes.rules.md
  - WaFormatDate — ./format-date.rules.md
  - WaFormatNumber — ./format-number.rules.md
  - WaIcon — ./icon.rules.md
  - WaInclude — ./include.rules.md
  - WaInput (Number Input anchor) — ./input.rules.md#number-input
  - WaPopover — ./popover.rules.md
  - WaPopup — ./popup.rules.md
  - WaProgressBar — ./progress-bar.rules.md
  - WaProgressRing — ./progress-ring.rules.md
  - WaQRCode — ./qr-code.rules.md
  - WaRadio / WaRadioGroup — ./radio.rules.md
  - WaRange (Slider) — ./slider.rules.md
  - WaRating — ./rating.rules.md
  - WaRelativeTime — ./relative-time.rules.md
  - WaScroller — ./scroller.rules.md
  - WaSelect / WaOption — ./select.rules.md
  - WaSkeleton — ./skeleton.rules.md
  - WaSpinner — ./spinner.rules.md
  - WaSplitPanel — ./split-panel.rules.md
  - WaTabGroup / WaTab / WaTabPanel — ./tab-group.rules.md
  - WaTag — ./tag.rules.md
  - WaText — ./text.rules.md
  - WaTextArea — ./textarea.rules.md
  - WaToastContainer / WaToastItem / WaToastDataService — ./toast.rules.md
  - WaTooltip — ./tooltip.rules.md
  - WaTree / WaTreeItem — ./tree.rules.md
  - WaSwitch — ./switch.rules.md
  - WaZoomableFrame — ./zoomable-frame.rules.md
- Testing and validation — ./testing.rules.md
- Release notes (forward-only) — ./release-notes.md
- Glossary (topic-first, prompt language) — ./GLOSSARY.md

See also
- JWebMP wrappers — ../README.md
- Base WebAwesome components — ../../webawesome/README.md
- Angular Awesome plugin — ../../angular-awesome/README.md
- Web Components — ../../webcomponents/README.md
- Angular language rules — ../../language/angular/README.md and angular-20 rules
- TypeScript language rules — ../../language/typescript/README.md
- CI/CD (GitHub Actions) — ../../platform/ci-cd/README.md and ../../platform/ci-cd/providers/github-actions.md
- Testing — ../../platform/testing/README.md, ../../platform/testing/jacoco.rules.md, ../../platform/testing/java-micro-harness.rules.md, ../../platform/testing/browserstack.rules.md
- Architecture diagrams (host repo) — docs/architecture/README.md
