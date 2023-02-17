# shell-apache-master-sync
Daily job that helps check if the latest superset-shell is compatible with the latest superset

Every day, pulls the latest preset-io/superset-shell and points it at the latest preset-io/superset.  Then pushes this to the `shell-apache-master-sync` branch so that superset-shell CI can run on it
