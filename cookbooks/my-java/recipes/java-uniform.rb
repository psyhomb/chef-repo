# Download jdk
# curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
# or
# curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
#
# Checksum is SHA256

java_version = node['java_version'][node.chef_environment]

directory "/usr/java"

java_version.each do |version, checksum|
  major = version[0]
  minor = version[-2..-1] 

  remote_file "/usr/java/jdk-#{version}-linux-x64.tar.gz" do
    source "http://download.oracle.com/otn-pub/java/jdk/#{version}-b13/jdk-#{version}-linux-x64.tar.gz"
    checksum "#{checksum}"
    headers({"Cookie" => "oraclelicense=accept"})
    #notifies :run, "bash[untar]", :immediately
    not_if { ::File.exists?("/usr/java/jdk1.#{major}.0_#{minor}") }
  end

  bash 'untar' do
    cwd '/usr/java'
    code <<-EOH
      (tar xzf jdk-#{version}-linux-x64.tar.gz && ln -s jdk1.#{major}.0_#{minor} latest#{major} && rm -rf jdk-#{version}-linux-x64.tar.gz)
      chown -R root. jdk1.#{major}.0_#{minor}
    EOH
    action :run
  end
end

# Vast version
#java_version = node['java_version'][node.chef_environment]
#
#java_version.each do |version, checksum|
#  major = version[0]
#  #minor = version[-2..-1]
#
#  java_ark "jdk-#{version}-linux-x64" do
#    url              "http://download.oracle.com/otn-pub/java/jdk/#{version}-b13/jdk-#{version}-linux-x64.tar.gz"
#    checksum         "#{checksum}"
#    app_home         "/usr/java/latest#{major}"
#    action :install
#  end
#end
