# Alexa Skill Kit Atom Integration

This Package builds on Amazons Alexa Skill Kit Command Line Interface [(ASK CLI)](https://developer.amazon.com/docs/smapi/quick-start-alexa-skills-kit-command-line-interface.html). It needs to be installed in order for this package to work. The ASK CLI is a tool to manage your Alexa skills and related AWS (Amazon Web Services) Lambda functions.

## Features

This Package integrates the `ask deploy` command into the Atom Status Bar. It allows you to either:

* click the Ask Button to deploy the whole skill
* `alt`-click to deploy the lambda function
* `shift`-click to deploy the model

You can also right-click the Ask Button to see all these options. Here you can also force deploy in case you need to overwrite changes you made to your skill online.

In the package Settings you can also enter a custom command you need to execute before deployment, such as transpiling your code. The command will run in the background from the project directory and it is not checked if it is executed successfully or not so make sure it works. You can execute multiple commands by seperating them with a `;`

You can also set the default deploy action. This only applies to clicking the Ask button, the `ask-integration:deploy` command will always deploy the whole skill.

## How it works

This packages relies on the ASK CLI. It executes the [`ask deploy`](https://developer.amazon.com/docs/smapi/ask-cli-command-reference.html#deploy-command) command with its flags in the background. When the deploy process is done Atom will notify you, if an error occurred it will be displayed as well.

It is automatically detected wether a project folder is an Alexa Skill directory. For this, the project folder needs to contain the `.ask` folder. If you don't see the Ask Button in the Status Bar try navigating to a file inside an Alexa Skill directory.
