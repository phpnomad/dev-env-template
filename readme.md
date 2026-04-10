# PHPNomad Dev Environment Template

A Docker-based development environment for building WordPress plugins that consume PHPNomad packages. It spins up WordPress, MySQL, and WP-CLI as containers, installs PHPUnit inside the WordPress container, and ships two helper scripts to handle setup and test runs.

The template assumes you're building a plugin that pulls in PHPNomad packages via path-type Composer repositories. The `setup.sh` script reads those paths out of your plugin's `composer.json`, clones each one from GitHub, runs `composer install`, and starts the Docker stack.

## Requirements

- Docker and Docker Compose
- Git, Composer, and `jq`
- A GitHub SSH key with access to the repositories you plan to clone

## How to use this template

Clone the repo and rename it for your project:

```bash
git clone git@github.com:phpnomad/dev-env-template.git your-plugin
cd your-plugin
```

Before running setup, open `setup.sh` and update the three spots that point at the plugin path. The script expects to find a `composer.json` with `repositories` entries of `type: path`, and it expects those paths to map onto GitHub repository names under a single organization. The defaults point at `plugins/phpnomad/composer.json` and `git@github.com:phpnomad/`, so change those to match your layout.

Then run:

```bash
chmod +x setup.sh
./setup.sh
```

The script clones your path dependencies, runs `composer install`, builds the Docker images, starts the containers, and waits for the database to come up. Once it finishes, WordPress is available at http://localhost:8000.

Pass `--force` to wipe and re-clone every dependency, or `--verbose` to see the underlying output.

## What's included

- A `wordpress` container built from `docker/Dockerfile` (WordPress on PHP 8.1 + Apache, with PHPUnit 9 pre-installed)
- A `db` container running MySQL 8.1, with database, user, and password all set to `test`
- A `wpcli` container using the `wordpress:cli` image for database resets and core installs
- `setup.sh`, which clones path-type dependencies, installs Composer packages, and brings the stack up
- `run-tests.sh`, which resets the database, reinstalls WordPress, and runs PHPUnit against `tests/phpunit.xml`

The three services share a `phpnomad` bridge network. WordPress files and MySQL data both live in named volumes (`wordpress_files`, `db_data`), so your containers survive restarts.

## Running tests

To run the full PHPUnit suite inside the container:

```bash
./run-tests.sh
```

To scope to a single test case or method:

```bash
./run-tests.sh --test-case=MyTestCase
./run-tests.sh --test-case=MyTestCase --test-method=testSomething
```

Because PHPUnit is installed directly in the WordPress container, you can also skip the helper entirely and point your IDE's test runner and XDebug at the container.

## Adding a dependency

Add a new `repositories` entry to your plugin's `composer.json` with `type: path`:

```json
{
    "type": "path",
    "url": "./plugin/packages/di"
}
```

The `url` needs to match the target GitHub repository name. For example, `git@github.com:phpnomad/di` maps to `./plugin/packages/di`. Re-run `./setup.sh` to clone the new dependency and update the autoloader.

## Troubleshooting

Check that your containers are running with `docker-compose ps`. If you hit permission errors, fix ownership on the mounted directories. Passing `--verbose` to `setup.sh` will show the output of each underlying command, which is usually enough to diagnose what went wrong during setup.

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
