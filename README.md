# GitLab Omnibus project

This project creates full-stack platform-specific [downloadable packages for GitLab][downloads].
For other installation options please see the
[GitLab project README][CE README].

## Installation

After the steps below your GitLab instance should reachable over HTTP,
and have an admin user with username `root` and password `5iveL!fe`.

### Ubuntu 12.04

```
sudo apt-get install openssh-server
sudo apt-get install postfix # sendmail or exim is also OK
sudo dpkg -i gitlab-x.y.z.deb # this is the .deb you downloaded
sudo gitlab-ctl reconfigure
```

### CentOS 6.5

```
sudo yum install openssh-server
sudo yum install postfix # sendmail or exim is also OK
sudo rpm -i gitlab-x.y.z.rpm
sudo gitlab-ctl reconfigure
# Open up the firewall for HTTP and SSH
sudo lokkit -s http -s ssh
```

## How to manage an Omnibus-installed GitLab

### Start/stop GitLab

You can start, stop or restart GitLab and all of its components with the
following commands.

```shell
# Start all GitLab components
sudo gitlab-ctl start

# Stop all GitLab components
sudo gitlab-ctl stop

# Restart all GitLab components
sudo gitlab-ctl restart
```

It is also possible to start, stop or restart individual components.

```shell
sudo gitlab-ctl restart unicorn
```

### Creating the gitlab.rb configuration file

```shell
sudo mkdir -p /etc/gitlab
sudo touch /etc/gitlab/gitlab.rb
sudo chmod 600 /etc/gitlab/gitlab.rb
```

### Configuring the external URL for GitLab

In order for GitLab to display correct repository clone links to your users
it needs to know the URL under which it is reached by your users, e.g.
`http://gitlab.example.com`. Add the following line to `/etc/gitlab/gitlab.rb`:

```ruby
external_url "http://gitlab.example.com"
```

Run `sudo gitlab-ctl reconfigure` for the change to take effect.

### Creating an application backup

To create a backup of your repositories and GitLab metadata, run the following command.

```shell
sudo gitlab-rake gitlab:backup:create
```

This will store a tar file in `/var/opt/gitlab/backups`. The filename will look like
`1393513186_gitlab_backup.tar`, where 1393513186 is a timestamp.

### Restoring an application backup

We will assume that you have installed GitLab from an omnibus package and run
`sudo gitlab-ctl reconfigure` at least once.

First make sure your backup tar file is in `/var/opt/gitlab/backups`.

```shell
sudo cp 1393513186_gitlab_backup.tar /var/opt/gitlab/backups/
```

Next, restore the backup by running the restore command. You need to specify the
timestamp of the backup you are restoring.

```shell
# This command will overwrite the contents of your GitLab database!
sudo gitlab-rake gitlab:backup:restore BACKUP=1393513186
```

If there is a GitLab version mismatch between your backup tar file and the installed
version of GitLab, the restore command will abort with an error. Install a package for
the [required version](https://www.gitlab.com/downloads/archives/) and try again.

### Invoking Rake tasks

To invoke a GitLab Rake task, use `gitlab-rake`. For example:

```shell
sudo gitlab-rake gitlab:check
```

Contrary to with a traditional GitLab installation, there is no need to change
the user or the `RAILS_ENV` environment variable; this is taken care of by the
`gitlab-rake` wrapper script.

### Directory structure

Omnibus-gitlab uses four different directories.

- `/opt/gitlab` holds application code for GitLab and its dependencies.
- `/var/opt/gitlab` holds application data and configuration files that
  `gitlab-ctl reconfigure` writes to.
- `/etc/gitlab` holds configuration files for omnibus-gitlab. These are
  the only files that you should ever have to edit manually.
- `/var/log/gitlab` contains all log data generated by components of
  omnibus-gitlab.

### Storing Git data in an alternative directory

By default, omnibus-gitlab stores Git repository data in `/var/opt/gitlab/git-data`.
You can change this location by adding the following line to `/etc/gitlab/gitlab.rb`.

```ruby
git_data_dir "/mnt/nas/git-data"
```

Run `sudo gitlab-ctl reconfigure` for the change to take effect.

## Building your own package

See [the separate build documentation](doc/build.md).

[downloads]: https://www.gitlab.com/downloads
[CE README]: https://gitlab.com/gitlab-org/gitlab-ce/blob/master/README.md
