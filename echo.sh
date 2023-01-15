# pull latest git repo from api and parse variables we need
download_path="\home\ansible_user";

releases=$(curl -s https://api.github.com/repos/paritytech/polkadot/releases/latest);
latest_version=$(echo $releases | jq -r '.tag_name' | awk -F "v" '{print $2}');
latest_file=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot") | .browser_download_url');
latest_filesha=$(echo $releases | jq -r '.assets[] | select(.name == "polkadot.sha256") | .browser_download_url');

current_release=$(polkadot --version | awk '{print $2}' | awk -F "-" '{print $1}');

prometheus_port=$1;
service_file=$2;

instance_version=$(curl -s http://localhost:$prometheus_port/metrics | grep substrate_build_info{ | awk -F ' ' '{ print $1 }' | awk -F { '{ print "{"$2}' | awk -F version=\" '{print $2}' | awk -F "-" '{print $1}');
is_parachain_validator=$(curl -s http://localhost:$prometheus_port/metrics | grep polkadot_node_is_parachain_validator{ | awk '{print $2}');

#Show variables attained
echo "Prometheus port : $prometheus_port";
echo "Service filename : $service_file";
echo "Download path: $download_path";

echo "Latest binary version : $latest_version";
echo "Current binary version : $current_release";
echo "Current instance version : $instance_version";

echo "Is Paravalidating: $is_parachain_validator";

if [ "$latest_version" == "$current_release" ]
then
    echo "Updating binary";
    echo "Downloading $latest_file";
    
    $(curl -sL $latest_file -o "$download_path\polkadot");
fi