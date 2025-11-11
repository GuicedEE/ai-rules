# Mutation Observer Rules

Defines usage rules for WebAwesome Mutation Observer.

## Overview
- Tag: `<wa-mutation-observer>`
- Purpose: Declarative interface to the MutationObserver API; observes DOM changes within the slotted content.
- React wrapper: WaMutationObserver (onWaMutation)
- Status: stable
- Since: 2.0

## Slots
- default — Content to watch for mutations.

## Events
- `wa-mutation` — Detail: `{ mutationList: MutationRecord[] }` emitted when one or more mutations occur.

### React wrapper event props
- Use `onWaMutation` to subscribe in React (WebAwesome React 3.0.0).

## Example
```html
<wa-mutation-observer>
  <div id="observed">Change me</div>
</wa-mutation-observer>
<script>
  const mo = document.querySelector('wa-mutation-observer');
  mo.addEventListener('wa-mutation', (ev) => {
    console.log('Mutations:', ev.detail.mutationList);
  });
  // Trigger a mutation
  document.getElementById('observed').textContent = 'Updated';
</script>
```

## Integration Notes
- Use for declarative observation. For advanced options (attributes, childList, subtree), consult WebAwesome docs to see if exposed as attributes; otherwise, fall back to native MutationObserver.
