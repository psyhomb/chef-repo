# Download jdk
# curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
# or
# curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O
#
# Checksum is SHA256

directory "/usr/java"

# Download oracle jdk archive file
remote_file "/usr/java/jdk-8u31-linux-x64.tar.gz" do
  source "http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz"
  checksum 'efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437'
  headers({"Cookie" => "oraclelicense=accept"})
  notifies :run, "bash[untar_jdk]", :immediately
  not_if { ::File.exists?('/usr/java/jdk1.8.0_31') }
end

bash 'untar_jdk' do
  cwd '/usr/java'
  code <<-EOH
    tar xzf jdk-8u31-linux-x64.tar.gz && ln -s jdk1.8.0_31 latest8 && rm -rf jdk-8u31-linux-x64.tar.gz
    chown -R root. jdk1.8.0_31
  EOH
  action :nothing
end

### TEST
#java_ark "jdk-8u31-linux-x64" do
#  url              'http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz'
#  checksum         'efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437'
#  app_home         '/usr/java/latest8'
#  action :install
#end

#http_request "jdk-8u31-linux-x64.tar.gz" do
#  message ""
#  url "http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz"
#  headers({"Cookie" => "oraclelicense=accept"})
#  notifies :create, "remote_file[jdk-8u31-linux-x64.tar.gz]", :immediately
#end
