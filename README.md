# Redmine Issue Templates Plugin

[![Plugin info at redmine.org](https://img.shields.io/badge/Redmine-plugin-green.svg?)](http://www.redmine.org/plugins/redmine_issue_templates)
[![Sider](https://img.shields.io/badge/Special%20Thanks!-Sider-blue.svg?)](https://sider.review/features)

Plugin to generate and use issue templates for each project to assist issue
creation.

## Supported browsers

The current version of Chrome, Firefox, and Microsoft Edge (Chromium version).

## Useful links

* Repository and Issues: <https://github.com/agileware-jp/redmine_issue_templates>
* Redmine Plugin List: <https://www.redmine.org/plugins/redmine_issue_templates>
* Wiki: <https://github.com/akiko-pusu/redmine_issue_templates/wiki>

If you have any feature requests or bug reports, please use [GitHub issues](<https://github.com/agileware-jp/redmine_issue_templates/issues>).

## Usage

### 1.) Plugin installation

* Copy the plugin directory into the `$REDMINE_ROOT/plugins` directory. Please
    note that plugin's folder name should be `redmine_issue_templates`. If
    changed, some migration tasks may fail.
* Run the migration task.

```bash
rails redmine:plugins:migrate RAILS_ENV=production
```

* (Re)Start Redmine.

#### Troubleshoot for bundle intall and startup problem

This plugin repository includes some test code and gem settings. If you have
some troubles related to `bundle install`, please try `--without` option.

```bash
bundle install --without test
```


### 2.) Uninstall

**Uninstall:**

```bash
rails redmine:plugins:migrate NAME=redmine_issue_templates VERSION=0 RAILS_ENV=production
```

**Re-install:**

```bash
rails redmine:plugins:migrate NAME=redmine_issue_templates RAILS_ENV=production
```

#### When migration error

If the migration is cancelled with error like following message for the first time you try to install this plugin:

> Caused by: Mysql2::Error: Table 'DATABASE_FOR_REDMINE.issue_templates' doesn't exist

You can fix this error to remove migration records related to this plugin from `shema_migrations` table.

If you can access and select database for Redmine, try this command:

```sql
select * from schema_migrations where version like '%redmine_issue_templates%';
```

If there are any records shown like this and there is no table named 'issue_templates', your installation has been in incomplete state.

```sql
1-redmine_issue_templates
2-redmine_issue_templates
```

So, you should better run the uninstall task first, and retry the migration.

**Related issues:**

* <https://github.com/akiko-pusu/redmine_issue_templates/issues/285>
* <https://github.com/akiko-pusu/redmine_issue_templates/issues/169>
* <https://github.com/akiko-pusu/redmine_issue_templates/issues/82#issuecomment-302000185>

### 3.) Required Settings

1. Login to your Redmine install as an Administrator
2. Enable the permissions for your Roles:

    * Show issue templates: User can show issue templates and use templates when creating/updating issues.
    * Edit issue templates: User can create/update/activate templates for each project.
    * Manage issue templates: User can edit help message of templates for each project.

3. Enable the module "Issue Template" on the project setting page.
4. The link to the plugin should appear on that project's navigation.

### 4.) Rake Tasks

You can see the rake tasks, related to this plugin, with `(bundle exec)` `rake -T`.

Exp.

```bash
# Apply inhelit template setting to child projects
$ rake redmine_issue_templates:apply_inhelit_template_to_child_projects[project_id]

# Run test for redmine_issue_template plugin
$ rake redmine_issue_templates:default

# Run spec for redmine_issue_template plugin
$ rake redmine_issue_templates:spec

# Run tests
$ rake redmine_issue_templates:test

# Unapply inhelit template setting from child projects
$ rake redmine_issue_templates:unapply_inhelit_template_from_child_projects[project_id]

# Generate YARD Documentation for redmine_issue_template plugin
$ rake redmine_issue_templates:yardoc
```

You can apply/unapply inherit templates for all the children projects.

```bash
rake redmine_issue_templates:apply_inhelit_template_to_child_projects[project_id]      # Apply inhelit template setting to child projects
rake redmine_issue_templates:unapply_inhelit_template_from_child_projects[project_id]  # Unapply inhelit template setting from child projects
```

If you want to apply inherit templates setting all the children projects of `project_id: 1` (as parent project), please run rake command like this:

```bash
rake redmine_issue_templates:apply_inhelit_template_to_child_projects[1]
```

### 5.) Testing

Please see `.circleci/config.yml` for more details.

```bash
% cd REDMINE_ROOT_DIR
% cp plugins/redmine_issue_templates/Gemfile.local plugins/redmine_issue_templates/Gemfile
% bundle install --with test
% export RAILS_ENV=test
% bundle exec ruby -I"lib:test" -I plugins/redmine_issue_templates/test plugins/redmine_issue_templates/test/functional/issue_templates_controller_test.rb
```

or

```bash
% bundle exec rails redmine_issue_templates:test
```

#### Run spec

Please see .circleci/config.yml for more details.

```bash
% cd REDMINE_ROOT_DIR
% cp plugins/redmine_issue_templates/Gemfile.local plugins/redmine_issue_templates/Gemfile
% bundle install --with test
% export RAILS_ENV=test
% bundle exec rspec -I plugins/redmine_issue_templates/spec --format documentation plugins/redmine_issue_templates/spec/
```

By default, `headless` is added as an option. If you set the environment variable
`HEADLESS` to `0`, `headless` will be removed.

```bash
% HEADLESS=0 bundle exec rspec -I plugins/redmine_issue_templates/spec --format documentation plugins/redmine_issue_templates/spec/
```

### 6.) Build scripts

required

* nodejs: 18.16.0

```bash
% npm install
% npm run build
```

#### Serve with vite-dev-server

```bash
% npm run dev
% REDMINE_ISSUE_TEMPLATE_VITE_SERVE_URL=http://localhost:5244 bundle exec rails server
```

### Changelog

For detailed list of changes please see: [CHANGELOG.md](CHANGELOG.md)

### Contributing

Pull requests, reporting issues, stars are always welcome!

We are always thrilled to receive pull requests, and do our best to process them as fast as possible.
If you find some type, please create pull request. Do it! We will appreciate it.

* Fork it!
* Create your feature branch: git checkout -b my-new-feature
* Commit your changes: git commit -am 'Add some feature'
* Push to the branch: git push origin my-new-feature
* Submit a pull request :D

### Language and I18n contributors

* Brazilian: Adriano Ceccarelli / Pedro Moritz de Carvalho Neto
* Korean: Jaebok Oh
* Chinese: Steven Wong, vongola12324 (zh-TW)
* Bulgarian: Ivan Cenov
* Russian: Denny Brain, danaivehr
* German: Terence Miller, Christian Friebel and anonymous contributor
* French: Anonymous one
* Serbian: Miodrag Milic
* Polish: Paweł Budikom and Krzysztof Wosinski
* Spanish: Andres Arias
* Italian: Luca Lesinigo
* Danish: AThomsen

### License

This software is licensed under the GNU GPL v2.
