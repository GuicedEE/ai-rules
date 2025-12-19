# Release Notes - Activity Master Client Rules (3.0.0-SNAPSHOT)

Summary (forward-only)
- Introduced modular rules for the client under rules/generative/data/activity-master/client, replacing the prior empty topic slot.
- Added lifecycle, builder, token cache, configuration, and testing rules aligned to GuicedEE + Vert.x 5 + Hibernate Reactive 7 with CRTP.
- Documented interface hierarchies and a topic glossary to enforce prompt-language alignment.

Impact
- Breaking for any prompts referencing legacy monoliths; update references to the new modular files listed above.
- No runtime code changes in this change set, but host documentation should now point to these rules for generation.

Follow-ups
- Keep docs/PROMPT_REFERENCE.md in sync if stack selections change.
- Add migration notes if future releases adjust API surfaces or cache behaviors.
