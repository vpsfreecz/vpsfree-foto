# vpsFree PhotoShow

The original vpsFree PhotoShow gallery, updated for PHP 8.5 while retaining its
appearance, year/album structure and native file/XML configuration. No database
is used. Source is built from the pinned original PhotoShow revision plus the
reviewed compatibility and security patch in `photoshow/php85.patch`.

The gallery keeps its original `foto` PHP-FPM pool and data paths:

- `/var/www/foto.vpsfree.cz/fotky_galerie`: original photographs and directories
- `/var/www/foto.vpsfree.cz/fotky_thumbs`: generated images, accounts, comments,
  settings and authoritative access-control XML
- `/var/lib/photoshow`: private runtime sessions, login limits and request lock

The executable application is immutable in the Nix store. Do not publish or put
data, account XML, passwords, backups, browser output or deployment receipts in
Git. Existing `admin_settings.ini`, accounts and ACL metadata are kept outside
the package. Never delete hidden generated XML as if it were disposable cache.

## NixOS

Import `nixos/gallery.nix` and enable `services.vpsfreePhotoShow.enable`. Set
`trustedProxyAddresses` to the actual TLS proxy addresses; direct clients must
not be able to spoof the login-limit identity. The module expects TLS termination
on the existing proxy and does not change DNS, certificates or other websites.
The original pool's worker counts and upload identity are retained. Old PHP
versions used by other pools are not changed by this module.

Build with `nix build .#default` and `nix build .#php`, or import
`photoshow/package.nix` and `photoshow/runtime.nix` with the host's pinned pkgs.
Run `php photoshow/tests.php /path/to/built/application` before deployment.
For integration/browser testing see `photoshow/README.md`; use only explicitly
owned synthetic fixtures and keep reports and credentials outside the repository.

The application accepts JPEG/PNG/GIF. The obsolete shell-based video encoder is
not enabled. Do not run seed/import helpers against existing production state.
The optional preview module and tools are for isolated test copies only.

## Source and license

PhotoShow is GPL-3.0-or-later, originally by Thibaud Rohmer and contributors:
https://github.com/thibaud-rohmer/PhotoShow. This derivative retains that license.
The fetched source retains embedded third-party license notices, including
PhpThumb's MIT license. See `COPYING` for the GNU GPL version 3.
