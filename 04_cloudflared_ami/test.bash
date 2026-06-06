#!/bin/bash
cd $(git rev-parse --show-toplevel)
tofu fmt -recursive
