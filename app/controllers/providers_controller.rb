UpHex::Pulse.controllers :providers do
  before do
    Ability::ProviderPolicy.new(current_ability).apply!
  end

  get '/:id' do
    @provider=Provider.find(params[:id])
    error(403) unless current_ability.can? :read, @provider
    render 'providers/show'
  end

  put '/:id' do
    @provider=Provider.find(params[:id])
    error(403) unless current_ability.can? :update, @provider
    @provider.update_attributes(params[:provider])
    if @provider.save
      flash[:notice] = t 'provider.modified'
      redirect "providers/#{@provider.id}?from=#{params[:from]}"
    else
      render 'providers/show'
    end
  end

  delete '/:id' do
    @provider=Provider.find(params[:id])
    error(403) unless current_ability.can? :delete, @provider
    @provider.deleted=true
    @provider.save!
    flash[:notice] = t 'provider.deleted'
    redirect "portfolios/#{@provider.portfolio.id}"
  end
end