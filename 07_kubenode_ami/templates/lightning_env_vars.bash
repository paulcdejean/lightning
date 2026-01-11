#!/bin/bash
if [[ -z "$AWS_USE_DUALSTACK_ENDPOINT" ]] ; then
  export AWS_USE_DUALSTACK_ENDPOINT=true
fi
