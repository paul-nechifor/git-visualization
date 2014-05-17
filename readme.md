# Git Visualization

Visualize local Git repos. (Work in progress.)

![Git Visualization](screenshot.png)

## Install

    npm install coffee-script -g
    npm install

## Build it

    npm run-script build

## Prerequisites

To use this you first have to install this.

    npm install git-plot -g

Then make a plot of your local Git usage. In this command I create the file for
all my commits (`--authorRegex 'Paul Nechifor'`) in the directory I store my
projects (`--searchDir /home/p/pro`).

    git-plot --searchDir /home/p/pro --authorRegex 'Paul Nechifor' -o build/s/commits.csv

## Run it

    node build/app.js

Go to [localhost:3000](http://localhost:3000).

## License

MIT
