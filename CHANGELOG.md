## Changelog

### 1.1.1

Bugfixes and support for Redmine 5.x. Thanks everybody for the contributions.

* Bugfix: fixed some typos in readme.md (@ace280)
* Bugfix: Fixed German mistranslation (@martinvonwittich) (#39)
* Bugfix: CircleCI configuration fixes (@sanak) (#41)
* Feature: Support for Redmine-5.x - zeitwerk etc. (@ishikawa999) (#11)
* Feature: Sort trackers in position order (@yui-har) (#6)
* Feature: Note templates improved (@yui-har) (#17, #26, #29)
* Feature: Testing improved - webdriver etc. (@yui-har) (#24)

### 1.1.0

Drop off the feature to integrate with Checklist plugin, for maintenance reason.
Please see for more details: <https://github.com/akiko-pusu/redmine_issue_templates/issues/363>

### 1.0.5

Bugfix and final release to support Checklist integration.
Please see: <https://github.com/akiko-pusu/redmine_issue_templates/issues/363>

* Bugfix: template_type is not defined error (GitHub: #364 / Thanks for reporting issue, @toku463ne)

### 1.0.4

Release to implemented some additional built-in/custom fields support.

* Feature: Add preselected watchers to templates. (GitHub: #302)
* Feature: Enabled to define assignees and categories. (GitHub: #362)
* Bugfix: Template duplicates when changing Status or Category fields. (GitHub: #354)
* Bugfix: Template body not loaded into issue answer (v.1.0.3 only) (GitHub: #356)
* Update JavaScript and Spec.

Thank you for the valuable information and feedback, @ChrisUHZ!

RESTRICTION: This version **is still not compatible with IE11**. (Related: #310)

### 1.0.3

NOTE: Mainly, maintenance, bugfix and refactoring only. There is no additional feature.

* Refactor JavaScript to work properly under jQuery 3.x (for Redmine trunk).
* Add some feature specs to test Builtin-fields support.

RESTRICTION: This version **is still not compatible with IE11**. (Related: #310)

### 1.0.2

Release to implememted Global note templates feature.

NOTE: **Migration is required** to use global note template.

* Feature: Implement Global Note Template. (GitHub: #268, #336)
* Feature: Improve the input form for built-In / custom fields setting. (GitHub: #345)
* Bugfix: Selecting note template browser "jumps" to top of page. (GitHub: #338)
* Bugfix: Change to make the selector more specific. Thanks, @sandratatarevicova (GitHub: #332, #333)
* Apply Bulgarian translation. Thanks, @jwalkerbg (GitHub: #330)
* Update README: `--without` argument for `bundle` is no longer necessary. (GitHub: #335 / by @vividtone)
* Update German Translation (by Christian Friebel).

RESTRICTION: This version **is still not compatible with IE11**. (Related: #310)

### 1.0.1

This is bugfix release against v1.0.0.
Updating to 1.0.1 is highly recommended, if you're using 1.0.0.
Migration is also required.

* Bugfix: Can't create a new templates optional settings. (GitHub: #322)
* Migration: Change the column type to text. (GitHub: #323)
* Update JavaScript.

Thank you for the valuable information and feedback, @AlUser71!

### 1.0.0

RESTRICTION: This version **is not compatible with IE11**. (Related: #310)
Please use version **0.3.8** or **[0.3-stable](https://github.com/akiko-pusu/redmine_issue_templates/tree/0.3-stable) branch** (uing jQuery version) if you need to support IE11.

NOTE: **Migration is required**.
Since ``Support Built-In / Custom Fields`` is an experimental feature, please **be careful** if you hope to try it.

* Feature: Add feature to show template usage / example (#303)
  * Using Vue.js v2.6.11
* Feature: Support Built-In / Custom Fields (#304)
* Rewrite JavaSctipt code from jQuery into plain JavaScript.

And some browsers may not work fine because Support Built-In / Custom Fields feature uses Vue.js for frontend.
So feedback, issue report, suggestion highly appreciate!

### 0.3.8

This is bugfix release.

* Bugfix: Fix that Issue Templates plugin changes the cursor icon for "Information" menu on Redmine's administration page (by vividtone, GitHub #316)
* Bugfix: Orphaned template list is not displayed (GitHub #337)
* Update Russian translation (GitHub #340)
* Update Bulgarian translation (GitHub #329)
* Update Korean translation (update Korean translation)
* Bugfix: enabled to create a new issue template setting. (GitHub #322)

### 0.3.7

This is bugfix release to prevent the conflict with other plugins.

* Bugfix: Tooltip for template body preview is hidden. (GitHub PR #300)
* Refactor: Change to use project menu to prevent the project setting tab's conflict. (GitHub PR #299)

Thank you for the valuable information and feedback, @ChrisUHZ!

### 0.3.6

This is bugfix release against v0.3.5.
Updating to 0.3.6 is highly recommended!

* Update zh-TW locale. #281 (by Vongola)
* Refactor: Update test code / Change Validation check.
* Add troubleshooting for migration error and uninstall.
* Add workaround to prevent other plugin's conflict. (#282)
* Add workaround to load right templates if the project has subproject and subproject selected. (#289)
* Apply the patch by @dmakurin to prevent the error when the user can't edit tracker id. (#288)
* Only wipe issue subject and description if replace flag. (#284,  Applied Pull Request by @mattgill)

### 0.3.5

NOTE: This version requires migration command to enhance note template's feature.
``Note Template visibility per role`` feature is still a prototype, so feedback highly appreciate!

* Design: PR / Mrliptontea theme compatibility #266 (by mrliptontea)
* Bugfix: #270 / Apply polyfill code for IE11. (reported by yui-har)
* Feature: Note Template visibility per role. #267
* Bugfix: Fix the request URL for accessing note_templates/load #261 (by ishikawa999)
* Bugfix: Note Template does not work on CKEDitor. #275
* Update README for contribution #273

### 0.3.4

This is bugfix release against v0.3.3.

* Add navigation link between issue template and note template.
* Refactor: Change to use let / const instead of var.
* Update test environment, especially E2E. (Follow up Redmine4.1)
* Bugfix #256 / Related to checklists.

### 0.3.3

This is bugfix release against v0.3.2.
Updating to 0.3.3 is highly recommended!

* Revert and Bugfix #230
  * Merge pull request #252 from ishikawa999/fix/248 by @ishikawa999
* Bugfix: #234 / Enable to save checklists when updating a template.

### 0.3.2

* Bugfix: Adding issue templates with checklists occurs internal error.(#243)
* Merge PR commit: bca2fe481 by @two-pack, restored missing newline. (Related: #242)
* Feature: Add clear subject/body option when tracker changed which has no template. (#230)
* Code refactoring.

### 0.3.1

* Basic feature implemented of note template.
* Enabled to use issue templates when updating issue.
  * Go to global template admin setting, and turn on "apply_template_when_edit_issue" flag.
* Bugfix: Prevent conflict against issue controller helper. (#217)
* Update readme: Merged PR #219. Thanks Arnaud Venturi!

NOTE: This version requires migration command to use note template feature.

```bash
rails redmine:plugins:migrate RAILS_ENV=production
```

### 0.3.0

* Support Redmine 4.x.
  * Now master branch unsupports Redmine 3.x.
  * Please use ver **0.2.x** or ``v0.2.x-support-Redmine3`` branch
    in case using Redmine3.x.
* Follow Redmine's preview option to the wiki toolbar.
* Show additional navigation message when plugin is applied to Redmine 3.x.

NOTE: Mainly, maintenance, bugfix and refactoring only. There is no additional feature, translation in this release.
Thank you for creating patch, Mizuki Ishikawa!

### 0.2.1

Mainly, bugfix and refactoring release.
Updating to 0.2.1 is highly recommended in case using CKEditor or MySQL replication.
NOTE: Migration is required, especially using MySQL replication.

* Bugfix: Fix "Page not found" error when try to create project template from project setting. (GitHub: #192, #199)
* Bugfix: Add composite unique index to support MySQL group replication. (GitHub: #197)
* Workaround: Wait fot 200 msec until CKE Editor's ajax callback done. (GitHub: #193)
* Add feature to hide confirmation dialog when overwritten issue subject and description, with using user cookie. (GitHub: #190)
* Refactoring: Minitest and so on.

A cookie named "issue_template_confirm_to_replace_hide_dialog" is stored from this release. (Related: #190)

### 0.2.0

Bugfix and refactoring release.
Updating from v0.1.9 to 0.2.0 is highly recommended.
In this release, some methods which implemented on Redmine v3.3 are ported
for plugin's compatibility. (To support Redmine 3.0 - 3.4)

* Bugfix: Prevent to call unimplemened methods prior to Redmine3.2. (GitHub: #180)
* Refactoring: Code format. (JS, CSS) / Update config for E2E test.
* Updated Simplified Chinese translation, thanks Steven.W. (GitHub PR: #179)
* Applied responsive layout against template list (index) page.

Thank you for reviewing, Tatsuya Saito!

For release notes before v0.2.0, please see: [RELEASE-NOTES.md](RELEASE-NOTES.md)