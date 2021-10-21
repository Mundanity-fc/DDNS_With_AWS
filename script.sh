#!bin/bash
#
# To use this script please make sure that aws-cli has already been installed and properly configured.
# If not installed, please try to install aws-cli with pip.
# If not configured, please run 'aws configure' to configure.
#

# Basic Var
DDNS_Recoed='A Record on dns.he.net'
DDNS_Domain="Domain on dns.he.net"
DDNS_Password='DDNS key for dns.he.net'
AWS_Instance_Name='Running Instance Name on AWS'
AWS_IP_Name='Name of the IP bound with Selected Instance'

# Special Var
Detect_Host='URL that needs detection'

# When the Detect Host refuses the request form AWS, Script will change the IP of AWS and reset the ddns record automatically.
Status_Code=$(curl -sIL --w "%{http_code}\n" -o /dev/null ${Detect_Host})
if [[ $Status_Code == 404 ]]
then
  aws lightsail release-static-ip --static-ip-name ${AWS_IP_Name}
  aws lightsail allowcate-static-ip --static-ip-name ${AWS_IP_Name}
  aws lightsail attach-static-ip --static-ip-name ${AWS_IP_Name} --instance-name ${AWS_Instance_Name}
  New_IP=$(aws lightsail get-static-ip --static-ip-name ${AWS_IP_Name} | grep ipAddress | grep -o -P "(\d+.\)(\d+\.)(\d+\.)\d+")
  curl "http://${DDNS_Recoed}:${DDNS_Password}@dyn.dns.he.net/nic/update?hostname=${DDNS_Domain}&myip=${New_IP}"
fi