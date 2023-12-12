# deleteOldProfiles Package

Mudlet continuiously creates backups of important data.  This can result in a lot
of files.  This package deletes old profiles, maps and modules in the 
"current", "map" and "moduleBackups" folders of the Mudlet home directory that are
no longer required.

The commands are;

```txt
> delete old profiles [days]
> delete old maps [days]
> delete old modules[days]
```

Days is optional, the default is 31 days.

The following files are NOT deleted:

- Files newer than the amount of days specified, or 31 days if not specified.
- One file for every month before that. Specifically: The first available file of every month prior to this.

```txt
-- Examples: 
> delete old profiles   -- deletes profiles older than 31 days  
> delete old maps 10    -- deletes maps older than 10 days
```
