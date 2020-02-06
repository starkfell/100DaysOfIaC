
# Day 94 - Blobxfer utility in long-term backup retention for PaaS DBs

Yesterday, we offered a solution for capturing and retaining Azure Database for Postgres backups for longer than the 35-day maximum, and we had a couple questions along the lines of "cloud this work for...?". And by-and-large, for any of the Azure DB flavors that have a retention cap that doesn't meet your needs, yes, Day 93 could be a starting point for solving this and a number of other potential Azure Storage scenarios. One of the key components in yesterday's script is the Azure **blobxfer** utility, which I find is unknown to most people. Today, we will quickly unpack blobxfer functionality and use.

In this article:

[What is blobxfer?](#what-is-blobxfer)
[Flavors of blobxfer](#flavors-of-blobxfer)
[Installing blobxfer](#installing-blobxfer)
[Sample install script (CLI)](#sample-install-script-cli)

## What is blobxfer?

Blobxfer is an advanced data movement tool and library for Azure Storage Blob and Files. With blobxfer you can copy your files into or out of Azure Storage with the CLI or integrate the blobxfer data movement library into your own Python scripts.

- Command-line interface (CLI) providing data movement capability to and from Azure Blob and File Storage
- Supports ingress, egress and synchronization of entire directories, containers and file shares
- Standalone library for integration with scripts or other Python packages
- High-performance design with asynchronous transfers and disk I/O
- YAML configuration driven execution support
- Fine-grained resume support including resuming a broken operation within a file or object

In short, I use blobxfer in the backup scenario because it provides *fast* and *reliable* transfer to Azure Blob and File Storage, and allows a broken operation to resume where it left off. Additionally, blobxfer includes a  `--file-md5` parameter, so I can specify that the MD5 hash should be computed and stored on the object I am copying to Azure Blob Storage. That enables a quick integrity check after the copy to ensure the backup arrived to its destination in the Azure Storage account intact.

> **NOTE**: The way Linux stores the MD5 hash and the way Azure stores the hash are quite different, so I had to use the Linux od (octal dump) utility to convert it to a hex value. For details, see the full backup script we published in [Day 93](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.93.postgres.ext.backups.md).

**Bottom line**: For any scenario where you need to copy data to Azure Storage FAST, blobxfer far outperforms the Azure PowerShell storage module the last time I tested. The core issue there was due to the fact that Azure PowerShell's storage module didn't leverage the full capabilities of the Azure Storage Data Movement library, but that is a story for another day. If you've seen an update that changes this reality, feel free to drop a comment.

## Flavors of blobxfer

While I use the blobxfer cli utility in shell scripts, blobxfer comes with some other options:

- **blobxfer Python Data Movement Library**. Handy if you want to use blobxfer in Python scripts.
- **blobxfer API**. A high-level blobxfer API is found in the blobxfer.api module. This module exposes each of the operations: Downloader, SyncCopy and Uploader.

## Installing blobxfer

There are three ways to install blobxfer:

- blobxfer Python package from PyPI
- Pre-built binaries available under Releases
- Docker images are available for both Linux and Windows platforms on the Microsoft Container Registry

## Sample install script (CLI)

Here's a bash snippet I use in Azure CLI scripts that will check for the presence of blobxfer, and if missing, will download and setup.

``` Bash
############################
# Verify blobxfer is present
############################

if [ -e "/usr/bin/blobxfer" ]; then
    echo "[$(date -u)][---info---] blobxfer is already installed."
else
    echo "[$(date -u)][---info---] blobxfer is not installed."

    # Installing blobxfer
    cd /usr/bin
    wget https://github.com/Azure/blobxfer/releases/download/1.8.0/blobxfer-1.8.0-linux-x86_64
    mv blobxfer-1.8.0-linux-x86_64 blobxfer
    chmod +x blobxfer

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed blobxfer."
    else
        echo "[$(date -u)][---fail---] Failed to install blobxfer."
        exit 2
    fi
fi
```

## Conclusion

I hope this provides some food for thought for your various Azure Storage scenarios where you need to move content quickly and reliably to-and-from Azure Storage. Have a question? Another topic you'd like to hear about? Drop us a comment on the "100 Days" repo.