#!/bin/sh
# ./clone.sh

if [ -d "./oscar" ]; then
    echo "already cloned"
else
    curl "http://jenkins.oscar-emr.com:8080/job/oscar-stable/lastSuccessfulBuild/artifact/*zip*/archive.zip" --output oscar.zip
    unzip oscar.zip
    mv archive oscar
    rm oscar.zip
    chmod a+x oscar/database/mysql/createdatabase_*.sh
fi

sudo mkdir -p /usr/local/docker-data/oscar-db
sudo chmod 777 /usr/local/docker-data/oscar-db

echo "Setting up database containers. This may take some time...."
docker-compose -f docker-compose-rel.yml up -d db
echo "Waiting for db containers initialize (1 min)"
docker-compose exec db ./code/populate-db.sh
echo "Bringing up tomcat"
docker-compose -f docker-compose-rel.yml up -d tomcat_oscar
docker-compose -f docker-compose-rel.yml up -d adminer

# echo "Waiting for containers to initialize (1 min)"
# sleep 60
# echo "Copying configuration files.."
# docker ps -a | awk '{ print $1,$2 }' | grep tomcat_oscar | awk '{print $1 }' | xargs -I {} docker exec -d {} chmod 755 /usr/local/tomcat/conf/copy.sh
# docker ps -a | awk '{ print $1,$2 }' | grep tomcat_oscar | awk '{print $1 }' | xargs -I {} docker exec -d {} /usr/local/tomcat/conf/copy.sh
# docker ps -a | awk '{ print $1,$2 }' | grep tomcat_oscar | awk '{print $1 }' | xargs -I {} docker restart {}
# echo "Restarting .."
# sleep 60

echo "OSCAR is set up at http://localhost:8091/oscar_mcmaster"
echo "You may have to restart the container http://localhost:8091/  (oscar/oscar)"
echo "Errors if any are more likely to be in the database import!"
echo "Thank You.."
echo "Visit our website for more info: http://nuchange.ca"