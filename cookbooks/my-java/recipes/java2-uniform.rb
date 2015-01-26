# Download jdk
# curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
# or
# curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
#
# Checksum is SHA256

# Vast version
java_versions = node['java_versions'][node.chef_environment]
java_home = "/usr/java"

java_versions.each do |version, checksum|
  major = version[0...version.index("u")]
  minor = version[version.index("u")+1..-1]

  java_ark "jdk-#{version}-linux-x64" do
    url              "http://192.168.1.144:8888/java/jdk-#{version}-linux-x64.tar.gz"
    checksum         "#{checksum}"
    app_home         "#{java_home}/latest#{major}"
    action :install
  end
end
