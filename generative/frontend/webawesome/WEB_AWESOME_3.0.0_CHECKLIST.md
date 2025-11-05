# WebAwesome React 3.0.0 Update Checklist

Purpose: Ensure our WebAwesome rules fully align with the WebAwesome React wrappers v3.0.0 and underlying web components.

This checklist is intended for maintainers when updating or validating component rules. Cross-linking to each component’s rule file is included.

## 1. Inventory and Coverage
- [x] Index updated to reflect all React 3.0.0 exports (see ./README.md)
- [x] Breadcrumb Item — ./breadcrumb-item.rules.md
- [x] Dropdown Item — ./dropdown-item.rules.md
- [x] Option — ./option.rules.md
- [x] Popover — ./popover.rules.md
- [x] Popup — ./popup.rules.md
- [x] Intersection Observer — ./intersection-observer.rules.md
- [x] Mutation Observer — ./mutation-observer.rules.md
- [x] Resize Observer — ./resize-observer.rules.md
- [x] Radio Group — ./radio-group.rules.md
- [x] Tab — ./tab.rules.md
- [x] Tab Panel — ./tab-panel.rules.md
- [x] Tree Item — ./tree-item.rules.md
- [x] Zoomable Frame — ./zoomable-frame.rules.md

Legacy (may not have React wrappers, but present as web components)
- [x] Icon Button — ./icon-button.rules.md
- [x] Menu — ./menu.rules.md

## 2. Rule File Completeness
For each rule file, verify the following sections are present and complete:
- [x] Overview: summary, tag name, purpose, status (if known), since version
- [x] Attributes/Properties: include types and defaults when known
- [x] Events: include names, payloads, cancelable notes if relevant
- [x] Slots: list all named and default slots
- [x] CSS Parts: list exported CSS parts
- [x] CSS Properties/States: when documented by WebAwesome types/docs
- [x] Accessibility: ARIA roles, labels, keyboard navigation
- [x] Examples: minimal and advanced
- [x] Integration Notes: framework-specific notes (e.g., event aliasing) if relevant to this repo

## 3. Breaking/Behavioral Changes in v3
- [x] Confirm any new events or renamed events are reflected (e.g., wa-after-show/hide)
- [x] Confirm React wrapper event props naming (e.g., onWaShow) in examples/notes
- [x] Observe new components introduced in v3 (e.g., Popover) and add rules

## 4. Cross-linking and Navigation
- [x] All new rules linked from ./README.md
- [x] Related components link to each other (e.g., Dropdown ↔ Dropdown Item, Select ↔ Option, Tab Group ↔ Tab ↔ Tab Panel)

## 5. Validation
- [x] Spot-check links by opening files and anchors
- [x] Ensure terminology uses WebAwesome component names (WaXxx) where wrappers are referenced
- [x] Ensure attributes/events match the React type definitions located under ./react/**

## 6. Observability of Changes
- [x] Document update in git history with message mentioning “WebAwesome React 3.0.0 rules sync”
- [x] Notify maintainers of any items needing deeper product documentation alignment

## 7. Follow-ups (if needed)
- [ ] Add examples for advanced patterns (async content, programmatic control)
- [ ] Add migration guides from 2.x to 3.0 for specific components if we discover breaking changes
