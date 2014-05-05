UpHex::Pulse.controllers :accounts do

  get '/me' do
    @account=current_user.accounts.first
    @organization=@account.organization
    render 'accounts/show'
  end

  put '/me' do
    @account=current_user.accounts.first
    @organization=@account.organization
    @organization.update_attributes(params[:organization])
    if @organization.save
      @organization.updated_at=Time.new
      @organization.save!
      @account.updated_at=Time.new
      @account.save!

      flash[:notice] = t 'authn.account.modified'
      redirect '/accounts/me'
    else
      render 'accounts/show'
    end
  end

end