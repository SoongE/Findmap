#!/bin/bash

# When we get killed, kill all our children
trap "exit" INT TERM
trap "kill 0" EXIT

# Source in utils.sh so we can have our nice tools
. $(cd $(dirname $0); pwd)/utils.sh

# first include any user configs if they've been mounted
template_user_configs

# Immediately run auto_enable_configs so that nginx is in a runnable state
auto_enable_configs

# Start up nginx, save PID so we can reload config inside of run_certbot.sh
nginx -g "daemon off;"
NGINX_PID=$!
