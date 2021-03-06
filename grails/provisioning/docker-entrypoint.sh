#!/bin/bash

USER=$(getent passwd grails 2>&1)
GROUP=$(getent group grails 2>&1)

echo "==> Attempting to create 'grails' user."

if [ ${#USER} == 0 ] && [ ${#GROUP} == 0 ]; then
    # Create the user with the given home directory.
    echo "    Creating user with UID:GID of ${GRAILS_UID}:${GRAILS_GID}"
    adduser -D -s /bin/bash -u ${GRAILS_UID} -g ${GRAILS_GID} -h ${GRAILS_HOME} grails

else
    echo "    User 'grails' already exists."
fi

echo "==> Attempting to create home directory at '${GRAILS_HOME}'."

# Create the home directory, if it doesn't already exist. We won't bother with the skeleton.
if [ ! -d "${GRAILS_HOME}" ]; then
    mkdir -p "${GRAILS_HOME}"
    echo "    Done!"
else
    echo "    Already exists!"
fi

echo "==> Fixing permissions"

chown ${GRAILS_UID}:${GRAILS_GID} "${GRAILS_HOME}"
chown ${GRAILS_UID}:${GRAILS_GID} "${GRAILS_WORKDIR}"

echo "    Done!"

cd "${GRAILS_WORKDIR}"

if [ ${RUN_APP} = true ]; then
  su grails -c "./gradlew --continuous bootRun"
else
  echo "==> Use 'docker exec -it -u grails <container_name> bash' to log into the container and create your app"
  tail -f /dev/null
fi
