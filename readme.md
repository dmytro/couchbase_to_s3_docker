
Couchbase backup to S3 using Docker
============================================

Docker container to run Couchbase backup and copy it to AWS S3 bucket.

Version 4.5 is at the time of writing Entrprise editions and contains
new backup binary `cbbackupmgr`, which is missing in pre 4.5
versions. Backup script in version 4.0.0 uses previous backup binary
`cbbackup`.


Dmytro Kovalov, dmytro.kovalov@gmail.com
June 2016, Tokyo
