A simple restic backup script

## Requirements:

1. restic binaries

Just install from your distro repositories or check [Restic Web](https://restic.net/)

2. restic repository

```bash
restic init -r ${RESTIC_HOME}/restic-repo
```
3. exec script

Change script variables based on your enviorment and exec it

```bash
./restic-backup.sh
```

4. check logs on ${RESTIC_HOME}/*.log
