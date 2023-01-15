# pull latest git repo from api and parse variables we need
releases=$(curl -s https://api.github.com/repos/paritytech/polkadot/releases/latest);
latest_version=$(echo $releases | jq -r '.tag_name');
latest_file=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot") | .browser_download_url');
latest_filesha=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot.sha256") | .browser_download_url');

prometheus_port=9700;

instance_version=$(curl -s http://localhost:$prometheus_port/metrics | grep substrate_build_info{ | awk -F ' ' '{ print $1 }' | awk -F { '{ print "{"$2}' | awk -F version=\" '{print $2}' | awk -F \" '{print $1}');

echo "Current binary version : $latest_version";
echo "Current instance version : $instance_version";
