#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")

# get credentials of live DB
source $DIR/db.secret.conf



RES=`mysql -u root -p$PASS -h 172.28.44.99 --port 3306 -e "SELECT * FROM (
   SELECT 'orgaSTAGE' DB, coms_training_organisation_name,  coms_training_organisation_id FROM bpmspace_coms_v1_STAGE.coms_training_organisation
   UNION ALL
   SELECT 'orgaTEST' DB, coms_training_organisation_name,  coms_training_organisation_id FROM bpmspace_coms_v1_TEST.coms_training_organisation
) t
GROUP BY  coms_training_organisation_name, coms_training_organisation_id
HAVING COUNT(*) > 1"`


if [ "$RES" != "" ]; then
    echo 'ANONYMAZATION FAILED'
fi
if [ "$RES" == "" ]; then
    echo 'DATA ANONYMAZED'
fi

RES=`mysql -u root -p$PASS -h 172.28.44.99 --port 3306 -e "SELECT * FROM (
   SELECT 'STAGE' DB, coms_participant_lastname, coms_participant_firstname, coms_participant_id FROM bpmspace_coms_v1_STAGE.coms_participant
   UNION ALL
   SELECT 'TEST' DB, coms_participant_lastname, coms_participant_firstname, coms_participant_id FROM bpmspace_coms_v1_TEST.coms_participant
) t
GROUP BY  coms_participant_lastname, coms_participant_firstname, coms_participant_id
HAVING COUNT(*) > 1"`


if [ "$RES" != "" ]; then
    echo 'ANONYMAZATION FAILED'
fi
if [ "$RES" == "" ]; then
    echo 'DATA ANONYMAZED'
fi
