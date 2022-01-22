#!/bin/bash

echo "Dumping database"
mysqldump -h $BACKUP_SERVER -u $BACKUP_USER -p"$BACKUP_PASSWORD" $BACKUP_DATABASE >backup.sql
echo "Restoring database"
mysql -u $RESTORE_USER -p"$RESTORE_PASSWORD" -h $RESTORE_SERVER $RESTORE_DATABASE <backup.sql
echo "Done"