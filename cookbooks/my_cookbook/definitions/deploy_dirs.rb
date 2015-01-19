define :deploy_dirs, :deploy_to => '' do
  directory "#{params[:deploy_to]}/test1"
  directory "#{params[:deploy_to]}/test2"
  directory "#{params[:deploy_to]}/test3"
end
