#!/bin/bash
slack='https://hooks.slack.com/services/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';
destination="/usr/local/bin/polkadot";
user=rbaksh-gs;
working=/home/rbaksh-gs;

echo `date`;
cd $working;

# pull latest git repo from api and parse variables we need
releases=$(curl -s https://api.github.com/repos/paritytech/polkadot/releases/latest);
latest_version=$(echo $releases | jq -r '.tag_name');
latest_file=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot") | .browser_download_url');
latest_filesha=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot.sha256") | .browser_download_url');

echo "Current release version : $latest_version";

# pull down sha and polkadot files
echo "Downloading : $latest_filesha";
wget -q $latest_filesha -O polkadot.sha256;
latest_sha=$(cat polkadot.sha256 | cut -d' ' -f1);
cur_sha=$(sha256sum $destination | cut -d' ' -f1);

#check the latest sha against the current sha
if [ "$latest_sha" == "$cur_sha" ]
then
   echo "The latest sha256 matches current, aborting."
   exit;
fi

echo "Downloading : $latest_file";
wget -q $latest_file -O polkadot;
new_sha=$(sha256sum polkadot | cut -d' ' -f1);

#check the latest sha against the new sha
if [ "$latest_sha" != "$new_sha" ]
then
   echo "Failed the sha256 check, aborting."
   exit;
fi

#compare binaries just to be sure, we should never fall into this
if [ "$(diff polkadot $destination)" == "" ]
then
    echo "The new and the current binary are the same, aborting."
    exit;
fi

#danger will robinson
chmod +x polkadot;
chown $user:$user polkadot;
new_version=$(runuser -l $user -c "$working/polkadot --version");
if [ "$new_version" == "" ]
then
    echo "The executable is not returning a version, aborting."
fi

echo "New Version Build : $new_version";

mv $destination "${destination}_old";
mv polkadot $destination;

#stop and start polkadot to use the new binary
echo "Polkadot : stopping";
systemctl stop polkadot;
echo "Polkadot: daemon-reload"
systemctl daemon-reload;
echo "Polkadot : starting";
systemctl start polkadot;
echo "System : Updated";

curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"*$HOSTNAME : Upgraded $new_version* \r\n\r\n $body\"}" $slack;
