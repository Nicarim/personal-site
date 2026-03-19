#!/usr/bin/env bash
set -e 

hugo

git add .
git commit --interactive

git subtree push --prefix public origin gh-pages