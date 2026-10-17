#!/bin/sh
set -eu

/app/bin/homebase eval 'Homebase.Release.setup()'
exec /app/bin/homebase start
