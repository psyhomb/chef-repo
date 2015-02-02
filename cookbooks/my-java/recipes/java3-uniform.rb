# Download jdk
# curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
# or
# curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
#
# Checksum is SHA256

# Checksum list
checksums = {
  "8u31" => "efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437",
  "7u51" => "77367c3ef36e0930bf3089fb41824f4b8cf55dcc8f43cce0868f7687a474f55c",
  "7u75" => "460959219b534dc23e34d77abc306e180b364069b9fc2b2265d964fa2c281610",
  "7u76" => "ce8ff4fed2cd16aea432edf8e94f21ccfe29e9d4a659bbbef3551982769e0c8c"
}

# Vast version
java_versions = node['java_versions'][node.chef_environment]
java_home = "/usr/java"

if java_versions.nil? or java_versions.empty?
  #Chef::Log.error("java_versions is nil or empty - Chef Environment: #{node.chef_environment}")
  #exit
  abort "java_versions is nil or empty - Chef Environment: #{node.chef_environment}"
end

java_versions.each do |version|
  major = version[0...version.index("u")]
  minor = version[version.index("u")+1..-1]

  java_ark "jdk-#{version}-linux-x64" do
    url              "http://java.buncici.com/jdk-#{version}-linux-x64.tar.gz"
    checksum         "#{checksums[version]}"
    app_home         "#{java_home}/latest#{major}"
    action :install
  end
end
