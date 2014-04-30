UpHex::Pulse.controllers :accounts do

  get '/me' do
    @account=current_user.accounts.first
    @organization=@account.organization
    params[:name]=@organization.name
    render 'accounts/show'
  end

  put '/me' do
    if params[:name].empty?
      flash.now[:name] = t 'authn.name.empty'
      error=true
    end
    if error
      @account=current_user.accounts.first
      render 'accounts/show'
    else
      account=current_user.accounts.first
      organization=account.organization
      organization.name=params[:name]
      organization.updated_at=Time.new
      account.updated_at=Time.new
      account.save!
      organization.save!
      flash[:notice] = t 'authn.account.modified'
      redirect '/accounts/me'
    end
  end

end