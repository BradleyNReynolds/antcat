##Change log
By no means a complete log. See also https://github.com/calacademy-research/antcat/wiki/Change-log-%28user-friendly%29.

* [Task completed] Removed initial import data in [6de106](https://github.com/calacademy/antcat/commit/6de1064967319876344be72098bd1db6dfcbef03)
* [Task completed] Removed *most* importers in [8e9a1c...8b6500](https://github.com/calacademy/antcat/compare/8e9a1cef3e461325c0b023ef66127d40915c1016...8b6500373e5874a2e6505a17a0597ed4cee48082)
* [Refactored] Converted *most* Formatters to Decorators in [94db1e...d64f03](https://github.com/calacademy/antcat/compare/94db1ea72bef8c5136bbcc11e46f9c84b82087ef...d64f038b806b1b79a72a706ae6a1e5b0a6802170)
* [Dormant code] Removed 'Preview' in [7a6deb](https://github.com/calacademy/antcat/commit/7a6deb25ab58bb4b95d963ab0461841c13611109), [14347e](https://github.com/calacademy/antcat/commit/14347eec6bdfef7770e37bc240816f6410821620)
* [Dormant code] Removed COins-related code in [1dc77d](https://github.com/calacademy/antcat/commit/1dc77dc115053574aef75b7c481ccec63aa6ca3c)
* [Dormant code] Removed Vlad in [64ada9](https://github.com/calacademy/antcat/commit/64ada9091bb6f11602b244d3ca48c24fdf393950), [c3881f](https://github.com/calacademy/antcat/commit/c3881f7fbdd24d643876b64cd5e80ffdbcad9761)
* [Dormant code] Removed taxon_utility.rb in [49879a](https://github.com/calacademy/antcat/commit/49879a6b653d98e8015a52b0d7318cdcf46b0c08)
* [Task completed] Removed HOL importers in b144164ca72f8d9f1a3b96c8f89947f1f7f34539. Related issues: #108, #98.
* [Dormant code / Task completed] Removed Bolton references-related code in [6e38e5](https://github.com/calacademy/antcat/commit/6e38e57afd636827c8f9c5142b86a9f0893f2240)
* Removed commented out code in [37064d](https://github.com/calacademy/antcat/commit/37064da56f47a530a388b268289a73cb24b93d75)
* [Hard to maintain] Removed 'edit references in place' feature in [604eee](https://github.com/calacademy/antcat/commit/604eee89bc25abd9202c579989a5163a5dd6539e)
* [Hard to maintain / edge-case / possibly introduces copy/paste errors] Removed 'copy reference' feature in [786d60](https://github.com/calacademy/antcat/commit/786d60b0d4e8395816e6a65b7248d2ef91c3897b)
* [Task completed] Removed HOL database tables in 62091524b8bdb956f6730f1f9893bc57ab06cfc0; data was migrated to `Taxon` in 529c73b2f8b03173647b5c5325a31890e1a2dfc5. We can use any 2016 db dump from before November 8 if we need to recreate. Related issues: #98.
* Removed 'replace missing references' feature. Likely unused (and dangerous) code that did not work as intended. TODO add hash.
