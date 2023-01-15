# pull latest git repo from api and parse variables we need
releases=$(curl -s https://api.github.com/repos/paritytech/polkadot/releases/latest);
latest_version=$(echo $releases | jq -r '.tag_name');
latest_file=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot") | .browser_download_url');
latest_filesha=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot.sha256") | .browser_download_url');

prometheus_port=$1;

instance_version=$(curl -s http://localhost:$prometheus_port/metrics | grep substrate_build_info{ | awk -F ' ' '{ print $1 }' | awk -F { '{ print "{"$2}' | awk -F version=\" '{print $2}' | awk -F "-" 'v''{print $1}');
is_parachain_validator=$(curl -s http://localhost:$prometheus_port/metrics | grep polkadot_node_is_parachain_validator | awk -F " " '{print $2}');

#Show variables attained
echo "Prometheus port : $prometheus_port";

echo "Current binary version : $latest_version";
echo "Current instance version : $instance_version";

echo "Is Paravalidating: $is_parachain_validator";
