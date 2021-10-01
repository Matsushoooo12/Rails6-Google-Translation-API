class TranslateController < ApplicationController
    def index
        project_id = ENV["CLOUD_PROJECT_ID"]

        translate = Google::Cloud::Translate.new version: :v2, project_id: project_id

        @text = "Hello, world!"

        target = "ja"

        @translation = translate.translate @text, to: target
    end
end
