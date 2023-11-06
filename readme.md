# PHPNomad WordPress Plugin Development

This repository holds the development environment for the PHPNomad WordPress Plugin. The environment consists of a set of composer packages and a Dockerized WordPress setup to facilitate easy development, testing, and integration of the plugin components.

## Introduction

The PHPNomad WordPress Plugin aims to provide a modular approach to WordPress development, leveraging the power of individual Composer packages to construct a comprehensive and extensible plugin. This approach not only promotes the single-responsibility principle but also makes maintenance and extension more manageable.

With a Dockerized setup, developers can work in a consistent and controlled environment, mitigating the "it works on my machine" problem. The integration with PHPUnit further ensures that all components work harmoniously and meet the expected behaviors.

## Setup Instructions

### Prerequisites

 * Ensure you have docker, docker-compose, git, composer, and jq installed on your machine.
 * SSH key added to your GitHub account for cloning repositories.

### Steps

```bash
git clone git@github.com:phpnomad/your-repo-name.git
cd your-repo-name
```

#### Find/Replace

This is technically a template, so there's several references to the `phpnomad` string. You can holistically replace this if you see fit, but there shouldn't be any harm in leaving it as-is if you prefer.

#### Prepare The Setup Script

A key step of the setup script is to clone all of your custom composer dependencies in the specified directory. This allows you to compile different package-based repository setups as-if they were a monorepo, without actually _making_ them a monorepo in the process.

It accomplishes this by cloning packages in a specified `composer.json` file. Each file inside this JSON that is marked as a `path` will be automatically cloned using the specified repo below.

The setup script has some boilerplate in-place that needs to be configured in-order to make this work as-expected. In the `setup.sh` script, you'll need to do a few things. First, change this:

```bash
packages=$(jq -r '.repositories[] | select(.type=="path") .url' plugins/phpnomad/composer.json)
```

So that the path `plugins/phpnomad/composer.json` actually goes to the path of your JSON file. This could be included as a part of a mu-plugin, or a custom WordPress plugin. Whatever works for you.

Once you have the package directory setup, you'll need to change the line that looks like this:

```bash
repo=$(echo $package | sed 's|\./lib/|git@github.com:phpnomad/|' | sed 's|$|.git|')
```

So that the `git@github.com:phpnomad/` matches the base for whatever your project is. Any git-based workflow should work, although only GitHub has been tested.

Next, you'll need to update the two lines that look like this:

```bash
git clone $repo "plugins/phpnomad/lib/$repo_name"
```
and
```bash
git clone $repo "plugins/phpnomad/lib/$repo_name" > /dev/null 2>&1
```

So that the files you wish to clone are being cloned in the proper directory. This can go to any directory, so if you want to use this to clone dependencies for a mu-plugin configuration, you can do that.

#### Run the setup script:

The setup script will automatically clone necessary Composer packages using Git. Then, it will setup the composer autoloader, and any non-git based dependencies. Finally, it will set up the Docker environment.

```bash
chmod +x setup.sh
./setup.sh
```

### Access WordPress:

After running the setup, you can access the WordPress instance by navigating to http://localhost:8000 in your browser.

## Run PHPUnit Tests:

To execute the PHPUnit tests inside the Docker environment:

```bash
./run-tests.sh
```

Under the hood, PHPUnit is installed directly onto the WordPress container, so if you want to use your IDE directly, with XDebug, you should be able to configure the container to function. This makes using the tests command no-longer necessary.

## Troubleshooting

If you face any issues with permissions, ensure the directories and files have the appropriate permissions set.
Ensure Docker containers are running by checking with docker-compose ps.

## Adding a New Dependency

To add a new dependency to the system, add it directly to the composer.json file you created for your project. Under "repositories".

```json
        {
            "type": "path",
            "url": "./plugin/packages/di"
        }
```

Make sure the "url" matches the git repository name, eg: `git@github.com:phpnomad/di` would be `./plugin/packages/di`.

Run `setup.sh` to update deps.