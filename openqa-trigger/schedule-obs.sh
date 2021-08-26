#! /bin/sh

set -e
unset OPENQA_CONFIG

function check_config {
  if [ -z "$OBS_TOOLS_OPENQA_KEY" ] && [ "${OBS_TOOLS_OPENQA_KEY+xxx}" = "xxx" ]; then
    echo "environment variable OBS_TOOLS_OPENQA_KEY is empty/unset"
    exit 1
  fi

  if [ -z "$OBS_TOOLS_OPENQA_SECRET" ] && [ "${OBS_TOOLS_OPENQA_SECRET+xxx}" = "xxx" ]; then
    echo "environment variable OBS_TOOLS_OPENQA_SECRET is empty/unset"
    exit 1
  fi
}

function trigger_run {
  OBS_VERSION="$1"
  FULL_URL="http://download.opensuse.org/repositories/OBS:/$2/"
  filename=`curl -s $FULL_URL | grep "obs-server.*.x86_64-.*\.qcow2\"" | head -n1 | sed -e 's,.*href=",,; s,".*,,; s,\.mirrorlist,,'`
  last_obs_filename="last_triggers/last.obs_$OBS_VERSION"
  ofilename=`cat $last_obs_filename || touch $last_obs_filename`
  if test "x$ofilename" != "x$filename"; then
    /usr/share/openqa/script/client isos post --host https://openqa.opensuse.org --apikey $OBS_TOOLS_OPENQA_KEY --apisecret $OBS_TOOLS_OPENQA_SECRET HDD_1_URL=$FULL_URL$filename DISTRI=obs ARCH=x86_64 VERSION=$OBS_VERSION BUILD=`echo $filename | sed -e 's,obs-server.*.x86_64-,,; s,Build,,; s,\.qcow2,,'` FLAVOR=Appliance
    echo $filename > $last_obs_filename
  fi
}

trigger_run Unstable Server:/Unstable/images
trigger_run 2.10 Server:/2.10:/Staging/images
