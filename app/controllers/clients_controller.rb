UpHex::Pulse.controllers :clients do
  get '/:id' do
    @client=Portfolio.find(params[:id])
    @clientevents=[]
    @clientstreams=[]
    render 'clients/show'
  end
end