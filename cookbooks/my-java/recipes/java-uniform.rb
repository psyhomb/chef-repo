# Download jdk
# curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
# or
# curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
#
# Checksum is SHA256

java_versions = node['java_versions'][node.chef_environment]
java_home = "/usr/java"

directory "#{java_home}"

java_versions.each do |version, checksum|
  major = version[0...version.index("u")]
  minor = version[version.index("u")+1..-1] 

  next if ::File.exists?("#{java_home}/jdk1.#{major}.0_#{minor}")

  remote_file "#{java_home}/jdk-#{version}-linux-x64.tar.gz" do
    source "http://download.oracle.com/otn-pub/java/jdk/#{version}-b13/jdk-#{version}-linux-x64.tar.gz"
    checksum "#{checksum}"
    headers({"Cookie" => "oraclelicense=accept"})
    #notifies :run, "bash[untar]", :immediately
    #not_if { ::File.exists?("#{java_home}/jdk1.#{major}.0_#{minor}") }
  end

  bash 'untar' do
    cwd "#{java_home}"
    code <<-EOH
    (
      tar xzf jdk-#{version}-linux-x64.tar.gz &&\
      rm -rf jdk-#{version}-linux-x64.tar.gz &&\
      ln -s jdk1.#{major}.0_#{minor} latest#{major} &&\
      chown -R root. jdk1.#{major}.0_#{minor}
    )
    EOH
    action :run
  end
end

# Vast version
#java_versions = node['java_versions'][node.chef_environment]
#java_home = "/usr/java"
#
#java_versions.each do |version, checksum|
#  major = version[0...version.index("u")]
#  minor = version[version.index("u")+1..-1]
#
#  java_ark "jdk-#{version}-linux-x64" do
#    url              "http://download.oracle.com/otn-pub/java/jdk/#{version}-b13/jdk-#{version}-linux-x64.tar.gz"
#    checksum         "#{checksum}"
#    app_home         "#{java_home}/latest#{major}"
#    action :install
#  end
#end
