# PhotoShow gallery

- Keep the original PhotoShow appearance, albums and native file/XML state.
  No database, Piwigo, redesign or changes to unrelated hosted websites.
- User authorized production publication on foto.vpsfree.cz on 2026-11-03.
  Preserve original photo/generated paths and the existing foto PHP-FPM pool.
- Keep credentials, account XML, photos, archives and test output outside Git.
  Pin official source/dependencies and scan all published content for secrets.
- Code is immutable; only the native photo/generated and session/state paths
  may be writable. Preserve direct-file ACL checks and the audited boundaries.
- Commit messages explain action and rationale, wrap at 80 columns and use
  git commit -F with a temporary message file. Preserve unrelated local work.
- Test image upload, album operations, roles/private URLs, original checksums
  and browser/mobile behavior. Delete only positively identified test fixtures.
