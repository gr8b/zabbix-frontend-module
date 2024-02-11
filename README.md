## How to

Use this repository as template to create your own repository.


## Notes

Git credentials should be set globally on host machine. When not set will required to configure in container console.

```sh
git config --global user.name username
git config --global user.email email@example.com
```

## Todo

- (+) start `install.sh` script only when container is created for first time
- checkout Zabbix branch to it own folder named by branch name in `/var/www/html`.
- (+) create module boilerplate if `manifest.json` is not present
- (+) if `manifest.json` is present use it version to filter out list of Zabbix branch allowed to checkout
- (+) use include path for inteliphense extension
- (+) init database and `conf/zabbix.conf.php` file
- add start/stop Zabbix server helper, make it as module copied during installation or `.bashrc` helper
- add helper to create action, view, asset file as `.bashrc` helper
