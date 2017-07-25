# EFS Borg Restore image

[`ndegardin/efs-borg-restore`](https://hub.docker.com/r/ndegardin/efs-borg-restore/)

An image to restore the content of an [AWS EFS](https://aws.amazon.com/efs/) cluster to another [AWS EFS](https://aws.amazon.com/efs/) cluster using the [Borg backup](https://borgbackup.readthedocs.io/) tool.

The backups must have been made with the [`ndegardin/efs-borg-backup`](https://hub.docker.com/r/ndegardin/efs-borg-backup/) container.  

## Features

When run, this container prompts for a **Borg repository** from the backup **EFS** filesystem (or mounted volume), and then for an archive. It then restores the content of the archive into the related source subdirectory of the source (original) **EFS** file system (or mounted volume).

This container will prompt interactively for a folder name, and an archive name. Consequently, it has to be run in command line, with the **docker** `-ti` options.

- Both the *source* and the *backup destination* can be either an **EFS** filesystem (maybe working with any **NFS** filesystem) or a **Docker** *mounted volume*
- Takes a passphrase in entry to decrypt the repository archive
- Keep a copy of the directory before the restoration (will be deleted on the next restoration)

## Usage

### As a **Docker** command to run a backup from a mounted volume to another mounted volume

    docker run -ti -v /my/original/volume:/my/source -v /my/backup/archives:/mnt/backup degardinn/efs-borg-restore MyPassPhrase

### As a **Docker** command to run a remote backup with EFS volumes

    docker run -ti degardinn/efs-borg-restore MyPassPhrase fs-a1b2c3d4.efs.us-east-1.amazonaws.com fs-c5d6e7f8.efs.us-east-1.amazonaws.com

### Command arguments

    docker run degardinn/efs-borg-restore <passphrase> <original EFS filesystem> <archives EFS filesystem> <folder name> <archive> <repo name>

With:
 - `passphrase`: the passphrase to use to encrypt the **Borg** repositories. Necesary to restore the archives
 - `original EFS filesystem`: the URL of the original **EFS** filesystem, where a folder will be restored. Will be mounted at `mnt/source`. If unspecified, this place can also be used to mount a **Docker** volume
 - `archives EFS filesystem`: the URL of the **EFS** filesystem containing the **borg** repositories, from where an archive will be restored. Will be mounted at `mnt/backup`. If unspecified, this place can also be used to mount a **Docker** volume.
 - `folder name`: the name of the folder of the original EFS filesystem to restore. If unspecified, will be asked interactively
 - `archive`: the name of the archive to restore. If unspecified, will be asked interactively
 - `repo name`: the repository name to use in the backup destination. `borg` per default