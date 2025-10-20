# HTML Templates (Modular Overview)

Start here when you see prompts about `<template>`, cloning, or declarative fragments.

- Why modular: Compact, AI-friendly reference.

## Quick start
- Define: `<template id="card-tpl">...static HTML...</template>`
- Use:
```javascript
const tpl = document.getElementById('card-tpl');
const node = tpl.content.cloneNode(true);
container.appendChild(node);
```
- Combine with Custom Elements: clone inside `connectedCallback` and bind events/props.

## Patterns and guidance
- Keep templates static; imperatively bind dynamic data after cloning.
- Reuse templates to avoid DOM construction overhead.
- Consider `<template shadowrootmode="open">` for declarative shadow DOM when applicable.

## See also
- Custom Elements — ./custom-elements.md
- Shadow DOM — ./shadow-dom.md
- ES Modules — ./es-modules.md
