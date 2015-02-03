# Authors: Milos Buncic and Ivan Savcic
# Description: Installs Oracle Java JDK based on the environment (defined through 'java-list' role)
#
###
#
# How to download Oracle Java JDK with curl
# Example:
#   curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
# or
#   curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O

# Local vars
env = node.chef_environment
java_home = "/usr/java"

# Recipe attributes
node.default['java_versions'][env] = nil

# List of Java versions
java_versions = node['java_versions'][env]

# Hash of checksums (SHA256)
checksums = {
  "8u31" => "efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437",
  "7u51" => "77367c3ef36e0930bf3089fb41824f4b8cf55dcc8f43cce0868f7687a474f55c",
  "7u75" => "460959219b534dc23e34d77abc306e180b364069b9fc2b2265d964fa2c281610",
  "7u76" => "ce8ff4fed2cd16aea432edf8e94f21ccfe29e9d4a659bbbef3551982769e0c8c"
}


# Exit if java_versions is nil
#abort "java_versions has nil value - Chef Environment: #{env}" if java_versions.nil?

# Show error msg in log if java_versions is nil
Chef::Log.error("java_versions is nil or empty - Chef Environment: #{env}") if java_versions.nil?

# Run installation of all java versions defined in java_versions list
java_versions.each do |version|
  major = version[0...version.index("u")]
  minor = version[version.index("u")+1..-1]

  java_ark "jdk-#{version}-linux-x64" do
    url        "http://java.buncici.com/jdk-#{version}-linux-x64.tar.gz"
    checksum   "#{checksums[version]}"
    app_home   "#{java_home}/latest#{major}"
    action     :install
  end
end
