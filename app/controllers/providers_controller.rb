UpHex::Pulse.controllers :providers do
  get '/:id' do
    @provider=Provider.find(params[:id])
    render 'providers/show'
  end

  put '/:id' do
    @provider=Provider.find(params[:id])
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
    @provider.destroy
    flash[:notice] = t 'provider.deleted'
    redirect "portfolios/#{@provider.portfolio.id}"
  end
end