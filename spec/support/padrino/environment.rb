def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end

def app_class
  Padrino.mounted_apps.first.app_constant
end
