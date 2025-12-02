# WaAvatar — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-avatar` and `wa-avatar-group`. Provides image/initials avatars with grouping support; matches ../../webawesome/avatar.rules.md behaviors.

Usage
- Use `WaAvatar` for single avatars and `WaAvatarGroup` to cluster multiple avatars (stacked/overlapped). Add directly to `WaCluster`/`WaStack`.
- Configure image src, alt text, shape/size/variant, and fallback initials via fluent setters; group controls max display/overflow indicator.
- Keep CRTP chaining; avoid builders.

Patterns
- Prefer accessible alt text and meaningful initials; avoid empty labels.
- When mixing with layout, place groups inside clusters; grid utilities belong on the cluster, not the avatar group.
- Follow theming/variant guidance from WebAwesome base rules.
