#!/bin/bash

echo -e "*_bso.sh\n.bso/" > ~/.gitignore
git config --global core.excludesFile "$HOME/.gitignore"