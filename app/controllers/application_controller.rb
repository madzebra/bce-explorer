module BceExplorer
  # Base Application controller class
  class ApplicationController < Sinatra::Base
    set :public_folder, File.expand_path('public', Env.root)
    set :views, File.expand_path('app/views', Env.root)
    set :haml, format: :html5, ugly: true

    helpers ApplicationHelper

    private

    def pjax?
      request.env['HTTP_X_PJAX'] || request['_pjax']
    end

    def render_with(template_name)
      haml settings.layout_name, layout: !pjax? do
        haml template_name
      end
    end
  end
end
